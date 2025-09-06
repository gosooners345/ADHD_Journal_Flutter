import 'dart:async';
import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../adhd_machine_learning/prediction_ui_state.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import '../project_resources/project_utils.dart';
import '../tokenizer.dart';
import 'symptom_selector_screen.dart';
import '../record_data_package/records_data_class_db.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:adhd_journal_flutter/project_resources/global_vars_andpaths.dart';
// ML Stuff
import 'package:adhd_journal_flutter/adhd_machine_learning/adhd_feature_service.dart';
import 'package:adhd_journal_flutter/project_resources/debouncer_utility.dart';

//import 'package:bitmap/bitmap.dart';


class NewComposeRecordsWidget extends StatefulWidget {
  const NewComposeRecordsWidget(
      {Key? key, required this.record, required this.id, required this.title})
      : super(key: key);
  final Records record;
  final String title;
  final int id;

  @override
  State<NewComposeRecordsWidget> createState() =>
      _NewComposeRecordsWidgetState();
}

class _NewComposeRecordsWidgetState extends State<NewComposeRecordsWidget> {
  final _formKey = GlobalKey<_NewComposeRecordsWidgetState>();

  // Text Controllers for views to contain data from loading in the record or storing data
  late IconButton nextButton;
  late IconButton prevButton;
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController emotionsController;
  late TextEditingController sourceController;
  late TextEditingController tagsController;
  late SwitchListTile successSwitch;
  final PageController _pageController = PageController();
  //Prediction stuff
  var _predictionStatus = PredictionIdle;
  Map<String,double>_predictionResults={};
  String _predictionError='';


  double? currentPage = 0;
  //New
  late TextEditingController sleepController;
  late TextEditingController medicationController;


  bool isChecked = false;
  Text successStateWidget = const Text('');
  String successLabelText = '';
  SizedBox space = const SizedBox(height: 16);
  SizedBox space2 = const SizedBox(height: 8);
  Text ratingSliderWidget = const Text('');
  Text sleepRatingWidget = const Text('');
  Uint8List pictureBytes = Uint8List(0);
  final ImagePicker picker = ImagePicker();
  ByteData data = ByteData(0);
  String ratingInfo = '';
  String symptomCoverText = "Tap here to add Symptoms";
 String sleepInfo='';
 double sleepRating=0.0;
 String medicationInfo='';
 //TextEditingController medicationTextController=TextEditingController();
// Add these controllers at the top of your _NewComposeRecordsWidgetState class
  final TextEditingController _symptomController = TextEditingController(); // For keywords
  final TextEditingController _contentController = TextEditingController(); // For main content (already there, ensure it's used)
  double _currentRating = 50.0; // Default rating


  //final AdhdMlService _inferenceService = AdhdMlService();
  final Debouncer _debouncer = Debouncer(milliseconds: 700); // Adjust debounce time as needed

  String? _livePrediction;
  Map<String,double>? _lastmodelprediction;

  ///For iOS Devices
  List<CameraDescription> cameras=[];
  CameraController? controller;
  bool isCamerainitialized = false;
  String cameraError = '';

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();

    customDate = super.widget.record.timeCreated;
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page;
      });
    });
    nextButton = IconButton(
      tooltip: "Next",
      onPressed: () {
        _pageController
            .nextPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInExpo)
            .whenComplete(() =>
            setState(() {
              currentPage = _pageController.page!;
            })
        );
      },
      icon: nextArrowIcon,
    );
    prevButton = IconButton(
      tooltip: "Previous",
      onPressed: () {
        _pageController
            .previousPage(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInExpo)
            .whenComplete(() =>
            setState(() {
              currentPage = _pageController.page!;
            })
        );
      },
      icon: backArrowIcon,
    );
    titleController = TextEditingController();
    contentController = TextEditingController(); // This is the original content controller
    emotionsController = TextEditingController();
    sourceController = TextEditingController();
    tagsController = TextEditingController();
   // sleepController = TextEditingController();
    medicationController = TextEditingController();


///Loading existing record code
    if (super.widget.id == 1) {
      // Load an existing record
      loadRecord();
      Future.delayed(const Duration(milliseconds: 100),_onInputChanged);
    } else {
      ratingInfo = 'Rating :';
      ratingSliderWidget = Text(ratingInfo);
      //Success Switch
      successLabelText = 'Success/Fail';
      successStateWidget = Text(successLabelText);

      sleepRatingWidget = Text(sleepInfo);



    }
    _updateRatingUI(super.widget.record.rating);
    _updateSuccessUI(super.widget.record.success);
    _updateSleepUI(super.widget.record.rating); // This should likely be super.widget.record.sleepRating or a similar field if you have one
    // Initialize _keywordController and _contentController if loading existing data
    _symptomController.text = super.widget.record.symptoms; // Example: or another field for keywords
    _contentController.text = super.widget.record.content; // Already initialized if id == 1
    _currentRating = super.widget.record.rating;

  }
  


//Prediction Methods
  Future<void> _runPrediction() async {
    // Gather all text inputs
    String keywordText = emotionsController.text.trim();
    String contentText = contentController.text.trim();
    String medicationText = medicationController.text.trim(); // NEW

    // --- VALIDATION ---
    if (keywordText.isEmpty || contentText.isEmpty) {
      print("Validation Error: Keywords and Content cannot be empty.");
      return;
    }

    // --- TOKENIZATION ---
    List<int> keywordTokens;
    List<int> contentTokens;
    List<int> medicationTokens; // NEW

    try {
      // Note: Assuming you have updated AdhdMlService to have these new constants from ml_definitions.json
      final int keywordLength = Global.adhdMlService.keywordSequenceLength;
      keywordTokens = MyTokenizer.tokenize(keywordText, vocabularyType: VocabularyType.keywords, maxLength: keywordLength);

      final int contentLength = Global.adhdMlService.contentSequenceLength;
      contentTokens = MyTokenizer.tokenize(contentText, vocabularyType: VocabularyType.content, maxLength: contentLength);

      // NEW: Tokenize medication
      final int medicationLength = Global.adhdMlService.medicationSequenceLength;
      medicationTokens = MyTokenizer.tokenize(medicationText, vocabularyType: VocabularyType.medication, maxLength: medicationLength);

    } catch (e) {
      print("Error during tokenization: $e");
      return; // Don't proceed
    }

    // --- NORMALIZATION ---
    // Note: Assuming you've updated AdhdMlService to have these methods/constants
    final List<double> normalizedRatingList = Global.adhdMlService.publicNormalizeRating(userRating: _currentRating);
    final List<double> normalizedSleepList = Global.adhdMlService.publicNormalizeSleep(userSleep:sleepRating); // NEW

    // --- LOGGING FOR DEBUG ---
    if (kDebugMode) {
      print('Dart: Sending keywords (count: ${keywordTokens.length})');
      print('Dart: Sending content (count: ${contentTokens.length})');
      print('Dart: Sending rating (normalized value: ${normalizedRatingList[0]})');
      print('Dart: Sending sleep (normalized value: ${normalizedSleepList[0]})'); // NEW
      print('Dart: Sending medication (count: ${medicationTokens.length})'); // NEW
    }

    // --- CALL NATIVE ---
    Map<String, double> result = {};
    try {
      result = await Global.adhdMlService.predict(
        widget.record, // This seems to be unused in the predict method now, can be removed if so
        keywords: keywordTokens,
        content: contentTokens,
        rating: normalizedRatingList,
        sleep: normalizedSleepList,      // NEW
        medication: medicationTokens,  // NEW
      );
    } catch (e) {
      print("Error during prediction: $e");
    }

    // --- UPDATE UI (This logic remains the same) ---
    if (result.isEmpty) {
      if (kDebugMode) {
        print("Prediction returned no results.");
      }
      setState(() {
        _livePrediction = "Insight: Could not generate a prediction";
      });
      return;
    } else {
      print("Prediction successful: $result");
      setState(() {
        _lastmodelprediction = result;
        final topPrediction = result.entries.reduce((a, b) => a.value > b.value ? a : b);
        final advice = _getPredictionAdvice(topPrediction.key);
        final String confidence = (topPrediction.value * 100).toStringAsFixed(1);
        _livePrediction = "Predicted Day Type: '${topPrediction.key}'\n$advice ($confidence% confidence)";
      });
      showMessage(_livePrediction!);
    }
  }






  Uint8List convertBytestoList(dynamic bytedata) {
    if (bytedata != null) {
      Uint8List list = Uint8List.fromList(bytedata);
      return list;
    } else {
      return Uint8List(0);
    }
  }

  DateTime customDate = DateTime.now();


  /// Image Widget
  Widget journalImage(ThemeSwap swapper) {
    //try {
    if (pictureBytes.isNotEmpty) {
      return uiCard(SizedBox(height: 500,
          width: 500,
          child: Image.memory(pictureBytes, fit: BoxFit.contain,)), swapper);
    } else {
      return uiCard(SizedBox(height: 500, width: 500, child:
      Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20,),
                Expanded(child:
                Text(
                    "No Picture, select camera or gallery to add a picture to this entry.",
                    style: TextStyle(fontSize: 30)))
              ])
          ])), swapper);
    }
  }

//Predictive advice
  String _getPredictionAdvice(String label) {
    print(label);
    switch (label) {
      case 'peak_performance_day':
        return 'Insight: This looks like a highly productive day! What strategies are working well?';
      case 'successful_day':
        return 'Insight: Trending towards a successful outcome. What positive steps are you taking?';
      case 'emotional_challenge_day':
        return 'Insight: Emotions are a key factor today. Consider mindfulness or emotional regulation strategies.';
      case 'inattentive_struggle_day':
        return 'Insight: This may be an inattentive day. Break tasks down, minimize distractions, or try a Pomodoro.';
      case 'executive_dysfunction_day':
        return 'Insight: Facing executive challenges? Try the "5-minute rule" or prioritize the most daunting task.';
      case 'high_stress_day':
        return 'Insight: Stress appears high. Remember to breathe, hydrate, and take short breaks.';
      case 'difficult_day':
        return 'Insight: A challenging day is predicted. Be kind to yourself and focus on small wins.';
      case 'neutral_day':
        return 'Insight: A balanced day predicted. Continue tracking your patterns!';
      default:
        return 'Insight: Your entry is being analyzed.';
    }
  }
  ///Camera Code - Don't Touch
  Future<void> initializeCamera() async{
    setState(() {
      isCamerainitialized = false;
       cameraError = '';
    });
    try{
      cameras = await availableCameras();
      if(cameras.isEmpty){
        print("No cameras available");
        setState(() {
          cameraError = "No cameras available";
        });
        return;
      }
      print("Available Cameras");
      for(var i=0; i<cameras.length; i++) {
        final camera = cameras[i];
        print("${camera.name} - ${camera.lensDirection}");
        CameraDescription? selectedCameraDesc;
        selectedCameraDesc = cameras.firstWhere(
                (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () {
              print("Could not find rear-facing camera on device");
              return cameras.first;
            }
        );
        controller = CameraController(
            selectedCameraDesc,
            ResolutionPreset.medium,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.jpeg
        );

        await controller!.initialize();
        if (!mounted) return;
        setState(() {
          isCamerainitialized = true;
        });
        print("Camera initialized successfully with ${selectedCameraDesc
            .name} at medium resolution");
      }}
  on CameraException catch (e) {
    if(mounted){
  setState(() {
    isCamerainitialized = false;
    cameraError = e.code;
  });      }
    } catch (e){
      if(mounted){
        setState(() {
          isCamerainitialized = false;
          cameraError = e.toString();
        });
    }}





  }
  Future<void> openCamera() async {
    try {
      if (Platform.isAndroid) {
        platform.setMethodCallHandler((call) async {
          if (call.method == "onPictureTaken") {
            final Uint8List imageBytes = call.arguments as Uint8List;
            print("Received ${imageBytes.lengthInBytes} bytes from native.");
            try {
              final testImage = await decodeImageFromList(imageBytes);
              print("NATIVE->DART: Bytes are a valid image (${testImage
                  .width}x${testImage.height}) before DB save.");
            } catch (e) {
              print(
                  "NATIVE->DART: ERROR - Bytes from native are ALREADY INVALID: $e");
              return; // Don't proceed to save invalid data
            }
            setState(() {
              pictureBytes = imageBytes;
            });
          } else if (call.method == "onPictureTakenError") {
            print("Native camera error: ${call.arguments}");
          }
          else if (call.method == "onPictureCancelled") {
            print("Native camera cancelled");
          }
        });
        await platform.invokeMethod('openCamera');
      }
      else {

        final dynamic result = await platform.invokeMethod('openCamera');
        if(result!=null && result is Uint8List){
          print("Received ${result.lengthInBytes} bytes from native.");
          try{
            final testImage = await decodeImageFromList(result);
            print("NATIVE->DART: Bytes are a valid image (${testImage.width}x${testImage.height}) before DB save.");
            setState(() {
              pictureBytes = result;
            });
          }catch(e){
print("NATIVE > DART: ERROR - Bytes from native are ALREADY INVALID: $e");
          }
        } else if (result == null){
          print("Native camera cancelled");
          setState(() {
            pictureBytes = Uint8List(0);
          });
        } else {
          print("Native camera error: $result");
        }

      }
    }
    on PlatformException catch (e) {
      if (kDebugMode) {
        print("Failed to open camera: '${e.message}");
      }
      setState((){
        pictureBytes = Uint8List(0);
      });


    } catch (e) {
      if (kDebugMode) {
        print("Failed to open camera: $e");
      }
      setState((){
        pictureBytes = Uint8List(0);
    });
  }
}

//ML Code
void _onInputChanged() {
    print("Debug #5, Bouncer will bounce.");
    _debouncer.run(() {
    _runPrediction();
    _predictOutcome();
    });
  }
  Future<void> _predictOutcome() async {


    // 1. Create a temporary Records object from current UI state
    // Ensure all fields used for prediction are included.
    final tempRecord = Records(
      //id: super.widget.record.id,
      title: titleController.text,
      content: contentController.text,
      emotions: emotionsController.text, // Use text from controller
      symptoms: widget.record.symptoms,  // Use the record's current symptoms string
      tags: tagsController.text,         // Use text from controller
      // Dummy values for the fields that are part of the model's LABEL, not its input.
      rating: _currentRating,
      success: widget.record.success!=null ? widget.record.success! : false,
      timeCreated: DateTime.now(),
      timeUpdated: DateTime.now(),
      media: pictureBytes,
      sources: sourceController.text,
      id: widget.record.id,
      sleep: sleepRating,
      medication: widget.record.medication,

    );

    // 2. Run the prediction
    final predictions = await Global.adhdMlService.predictRecord(tempRecord); // Changed to predictRecord
_lastmodelprediction = predictions;
print(_lastmodelprediction);
    // 3. Find the most likely outcome
    if (predictions.isNotEmpty) {
      final topPrediction = predictions.entries.reduce((a, b) => a.value > b.value ? a : b);

      // Get the advice/explanation for the prediction
      final advice = _getPredictionAdvice(topPrediction.key);
      final String confidence = (topPrediction.value * 100).toStringAsFixed(1);
      // 4. Update the UI state with the result
      setState(() {
        _livePrediction = "Predicted Day Type: '${topPrediction.key}'\n$advice ($confidence% confidence)";
        showMessage(_livePrediction!);
      });
    } else {
      setState(() {
        _livePrediction = null; // Clear if no prediction is made (e.g., empty input)
      });
      print("Live Prediction is null");
    return;
    }

  }

///UI Updating code
  void _updateRatingUI (double newRating){
    super.widget.record.rating = newRating;
    _currentRating = newRating; // Update _currentRating

    if (super.widget.record.rating == 100.0) {
      ratingInfo = "Rating : Perfect ";
    } else if (super.widget.record.rating >= 85.0 &&
        super.widget.record.rating < 100.0) {
      ratingInfo = 'Rating : Great';
    } else if (super.widget.record.rating >= 70.0 &&
        super.widget.record.rating < 85.0) {
      ratingInfo = 'Rating : Good';
    } else if (super.widget.record.rating >= 55.0 &&
        super.widget.record.rating < 70.0) {
      ratingInfo = 'Rating : Okay';
    } else if (super.widget.record.rating >= 40.0 &&
        super.widget.record.rating < 55.0) {
      ratingInfo = 'Rating : Could be better';
    } else if (super.widget.record.rating >= 25.0 &&
        super.widget.record.rating < 40.0) {
      ratingInfo = 'Rating : Not going well';
    } else if (super.widget.record.rating < 25.0) {
      ratingInfo = 'Rating : It\'s a mess';
    }
    setState(() {
      ratingSliderWidget = Text(ratingInfo);
    });
    _onInputChanged();
    //_predictOutcome();
  }

  void _updateSleepUI(double newSleepRating) {


    sleepRating = newSleepRating; // Update the local state variable for the slider

    if (sleepRating == 100.0) {
      sleepInfo = "Sleep : Perfect ";
    } else if (sleepRating >= 85.0 && sleepRating < 100.0) {
      sleepInfo = 'Sleep : Great';
    } else if (sleepRating >= 70.0 && sleepRating < 85.0) {
      sleepInfo = 'Sleep : Good';
    } else if (sleepRating >= 55.0 && sleepRating < 70.0) {
      sleepInfo = 'Sleep : Okay';
    } else if (sleepRating >= 25.0 && sleepRating < 55.0) {
      sleepInfo = 'Sleep : Poor';
    } else { // Handles < 25.0 and potentially 0.0 or other edge cases
      sleepInfo = 'Sleep : Very Poor/None';
    }
    setState(() {
      sleepRatingWidget = Text(sleepInfo);
    });
    _onInputChanged();
    //_predictOutcome();// Assuming you want to trigger prediction on sleep change as well
  }
  void _updateSuccessUI(bool value) {
    widget.record.success = value;
    isChecked = value;
    if(value){
      successLabelText = 'Success';
    } else {
      successLabelText = 'Fail';
    }
    setState(() {
      successStateWidget = Text(successLabelText);
    });
    _onInputChanged();
    //_predictOutcome();
  }

  ///Manages the Pages
  Widget _buildPageIndicator(ThemeSwap swapper,int pageCount) {
    return Align(
      alignment: Alignment.bottomCenter,
      child:
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0), // Add some padding
        child: SmoothPageIndicator(
          controller: _pageController,
          count: pageCount,
          effect: WormEffect(
            dotHeight: 12,
            dotWidth: 12,
            activeDotColor: Color(swapper.isColorSeed), // Use activeDotColor
            dotColor: Colors.grey, // Specify inactive color
          ),
          onDotClicked: (value) {
            _pageController.animateToPage(
              value,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
    );
  }

  //The Journal cards themselves
  PageView _buildJournalCards(ThemeSwap swapper) {
    return PageView(
      controller: _pageController,
      onPageChanged: (page) {
        _pageController.animateToPage(page,
            duration: const Duration(milliseconds: 100), curve: Curves.easeIn);
      },
      children: [
        ///When the event took place if not recently 1.
        uiCard(
            Column(children: [
              const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                      child: Text("When did this event take place?",
                          style: TextStyle(fontSize: 20)))),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child:
                Card(child: ListTile(leading: const Icon(Icons.calendar_today),
                    title: Text(
                      "Date: ${customDate.month}/${customDate.day}/${customDate
                          .year}\r\n Time: ${customDate.hour}:${customDate.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 20),),
                    onTap: () async {
                      selectDate(context);
                    }),

                ),
              ),
            ]),
            swapper),

        /// Title 2.
        uiCard(
            Column(children: [
              const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                      child: Text("What do you want to call this?",
                          style: TextStyle(fontSize: 20)))),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color: Color(colorSeed).withOpacity(1.0),
                              width: 1)),
                      // labelText: 'What do you want to call this?'
                      hintText: "Enter the title of this entry here."),
                  textCapitalization: TextCapitalization.sentences,
                  controller: titleController,
                  onChanged: (text) {
                    super.widget.record.title = text;
                    //_onInputChanged();
                  },
                ),
              ),
            ]),
            swapper),

       //Content 3.
        uiCard(
            Column(children: [
              const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                      child: Text(
                        "What's on your mind?",
                        style: TextStyle(fontSize: 20),
                      ))),
              const SizedBox(
                height: 10,
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                                color:
                                Color(swapper.isColorSeed).withOpacity(1.0),
                                width:
                                1)), //labelText: 'What\'s on your mind? ',
                        hintText:
                        "Enter what happened here or what you're thinking about."),
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    controller: contentController, // Use _contentController here
                    onChanged: (text) {
                      super.widget.record.content = text;
                      //_onInputChanged();
                    },
                  )),
              space
            ]),
            swapper),

        /// Emotions 4.
        uiCard(
            Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                        child: Text("How do you feel currently?",
                            style: TextStyle(fontSize: 20)))),
                space,
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                  color: Color(swapper.isColorSeed)
                                      .withOpacity(1.0),
                                  width: 1)),
                          /*labelText: 'How do you feel today?',*/
                          hintText: "Enter how you're feeling here."),
                      controller: emotionsController,
                      onChanged: (text) {
                        super.widget.record.emotions = text;
                        _onInputChanged();
                      },
                    )),
              ],
            ),
            swapper),

        /// Surrounding Circumstances 5.
        uiCard(
            Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                        child: Text(
                            "Is there anything that may have contributed to this?",
                            style: TextStyle(fontSize: 20.0)))),
                space,
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(
                                  color:
                                  AppColors.mainAppColor.withOpacity(1.0),
                                  width: 1)),
                          labelText:
                          'This is where stuff like preexisting triggers, preliminary events, etc. can go.',
                          hintText:
                          'Add your thoughts or what you think could\'ve triggered this here'),
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      scrollController: ScrollController(),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      controller: sourceController,
                      onChanged: (text) {
                        super.widget.record.sources = text;
                        //_onInputChanged();
                      },
                    )),
                space
              ],
            ),
            swapper),

        /// Related ADHD Symptoms 6.
        uiCard(
            Column(
              children: [
                Padding(padding: EdgeInsets.all(10),child: Text("What symptoms are affecting you today?"),)
                ,space,
                 ListTile(
                    title: Text(super.widget.record.symptoms == "" ? "Tap here to select relevant symptoms. ": "Current Symptoms: ${super.widget.record.symptoms}"),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  SymptomSelectorScreen(
                                    symptoms: super.widget.record.symptoms,
                                  ))).then((value) {
                        setState(() {
                          super.widget.record.symptoms = value as String;
                        });
             _onInputChanged();
                      });
                    },
                  ),
              ],
            ),
            swapper),
       //Sleep 7.
        uiCard(Column(children: [Padding(padding: EdgeInsets.all(10),child: Text("How well did you sleep last night?"),),
        space,
          Padding(
              padding: const EdgeInsets.all(10),
              child: Center(child: sleepRatingWidget)),
          Slider( // This slider should control the sleepRating
              value: sleepRating, // Use sleepRating here
              onChanged: (double value) {
                _updateSleepUI(value);
              },
              max: 100.0,
              min: 0.0,
              divisions: 100,
              label: sleepRating.toStringAsFixed(1)), // Display sleepRating value
        ],),swapper),
        //Medication 8.
        uiCard(Column(children: [Padding(padding: EdgeInsets.all(10),child: Text("Medication Taken?"),),
        space,
          Padding(padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                          color: Color(swapper.isColorSeed).withOpacity(1.0),
                          width: 1)),
                  // labelText: 'What do you want to call this?'
                  hintText: "Enter your medication here."),
              textCapitalization: TextCapitalization.sentences,
              controller: medicationController,
              onChanged: (text) {

                setState(() {
                  medicationInfo = text;
                });
              },
            ),)
        ],),swapper),

//Tags 9.
        uiCard(
            Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "Tags",
                        style: TextStyle(fontSize: 20),
                      ),
                    )),
                space,
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                                color:
                                Color(swapper.isColorSeed).withOpacity(1.0),
                                width: 1)),
                        hintText: 'Add event tags here.',
                        labelText: 'What categories does this fall under?',
                      ),
                      controller: tagsController,
                      onChanged: (text) {
                        super.widget.record.tags = text;
                        //_onInputChanged();
                      },
                    )),
              ],
            ),
            swapper),

       //Rating 10.
        uiCard(
            Column(
              children: [
                const Padding(
                    padding: EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        "How would you rate this?",
                        style: TextStyle(fontSize: 20),
                      ),
                    )),
                space,
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: ratingSliderWidget)),
                Slider(
                    value: _currentRating, // Use _currentRating here
                    onChanged: (double value) {
                      _updateRatingUI(value);
                      _onInputChanged();
                    },
                    max: 100.0,
                    min: 0.0,
                    divisions: 100,
                    label: _currentRating.toStringAsFixed(1)), // Use _currentRating here
              ],
            ),
            swapper),

        /// Success/Fail 11.
        uiCard(
            Column(children: [
              const Padding(
                  padding: EdgeInsets.all(10),
                  child: Center(
                      child: Text("Do you think what happened was successful? ",
                          style: TextStyle(fontSize: 20)))),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SwitchListTile(
                  value: isChecked,
                  onChanged: (bool value) {
                    _updateSuccessUI(value);
                    _onInputChanged();
                  },
                  title: successStateWidget,
                  activeColor: Color(swapper.isColorSeed),
                ),
              ),
               if (_livePrediction != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _livePrediction!,
                    style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                    textAlign: TextAlign.center,
                  ),
                ),
            ]),
            swapper),

        ///Add Pictures or other media here 12.
        uiCard(Column(mainAxisAlignment: MainAxisAlignment.center, spacing: 5.0,
          children: [
            Row(spacing: 8.0,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Choose a picture to define this entry",
                  style: TextStyle(fontSize: 20),)
              ],),
            space,
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(children: [
                          Icon(Icons.camera, size: 40.0, color: Color(swapper
                              .isColorSeed)),
                          Text("Camera")
                        ],)),
                    onTap: () async {
                      await openCamera().then((value) {
                        setState(() {
                          super.widget.record.media = pictureBytes;
                        });
                      });
                    },),
                  GestureDetector(child:
                  Padding(padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        Icon(
                            Icons.photo_size_select_actual_outlined, size: 40.0,
                            color: Color(swapper.isColorSeed)),
                        Text("Gallery")
                      ],)),
                      onTap: () {
                        pickImageFromGallery();
                      })
                ]),
            space,
            Expanded(child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: ConstrainedBox(constraints: BoxConstraints(
                  maxWidth: MediaQuery
                      .of(context)
                      .size
                      .width * 0.8, // Example max width
                  maxHeight: 300, // Example max height
                ), child: FittedBox(
                  fit: BoxFit.contain,
                  child: journalImage(swapper),
                ))),
              ],))
,space
          ],

        ), swapper),

        ///Entry Review 13.
        uiCard(
            ListView(
              padding: const EdgeInsets.only(
                  left: 10, top: 20, right: 10, bottom: 40),
              shrinkWrap: true,
              children: <Widget>[
                const Text(
                    "Here's what you entered. Check and see if everything is correct. Once you're done, hit save.",
                    style: TextStyle(fontSize: 20)),
                space,
                //Title Field
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color:
                              Color(swapper.isColorSeed).withOpacity(1.0),
                              width: 1)),
                      labelText: 'What do you want to call this?'),
                  textCapitalization: TextCapitalization.sentences,
                  controller: titleController,
                  onChanged: (text) {
                    super.widget.record.title = text;

                  },
                ), //x
                space,

                //Date Field
                Card(child: ListTile(leading: const Icon(Icons.calendar_today),
                    title: Text(
                      "Date: ${customDate.month}/${customDate.day}/${customDate
                          .year} ${customDate.hour}:${customDate.minute.toString().padLeft(2, '0')}", style: const TextStyle(fontSize: 20),),
                    onTap: () async {
                      selectDate(context);
                    }),),
                space,
                // Content Field
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: Color(swapper.isColorSeed).withOpacity(1.0),
                            width: 1)),
                    labelText: 'What\'s on your mind? ',
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  controller: contentController, // Use _contentController here
                  onChanged: (text) {
                    super.widget.record.content = text;
                    //_onInputChanged();
                  },
                ), //x
                space,
                //Emotions Field
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: Color(swapper.isColorSeed).withOpacity(1.0),
                            width: 1)),
                    labelText: 'How do you feel today?',
                  ),
                  controller: emotionsController,
                  onChanged: (text) {
                    super.widget.record.emotions = text;
                    _onInputChanged();
                    //_predictOutcome();
                  },
                ), //x
                space,
                //Source Field
                TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color: AppColors.mainAppColor.withOpacity(1.0),
                              width: 1)),
                      labelText: 'Do you have anything to add to this?',
                      hintText:
                      'Add your thoughts or what you think could\'ve triggered this here'),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  controller: sourceController,
                  onChanged: (text) {
                    super.widget.record.sources = text;
                  //  _onInputChanged();
                  },
                ), //x
                space,
                //Symptom Field
                ListTile(
                  title: Text(super.widget.record.symptoms == "" ? symptomCoverText : "Current Symptoms: ${super.widget.record.symptoms}"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                SymptomSelectorScreen(
                                  symptoms: super.widget.record.symptoms,
                                ))).then((value) {
                      setState(() {
                        super.widget.record.symptoms = value as String;

                      });
                      _onInputChanged();
                      //_predictOutcome();
                    });
                  },
                )
                ,space,
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: Color(swapper.isColorSeed).withOpacity(1.0),
                            width: 1)),
                    hintText: 'Add event tags here.',
                    labelText: 'What categories does this fall under?',
                  ),
                  controller: tagsController,
                  onChanged: (text) {
                    super.widget.record.tags = text;
                  //  _onInputChanged();
                  },
                ),
                space,
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(child: sleepRatingWidget)),
                Slider( // This slider should control the sleepRating
                    value: sleepRating, // Use sleepRating here
                    onChanged: (double value) {
                      _updateSleepUI(value);
                    },
                    max: 100.0,
                    min: 0.0,
                    divisions: 100,
                    label: sleepRating.toStringAsFixed(1)),
                space,

                Padding(padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide(
                                color: Color(swapper.isColorSeed).withOpacity(1.0),
                                width: 1)),
                         //labelText: '',
                        hintText: "Enter your medication here."),
                    textCapitalization: TextCapitalization.sentences,
                    controller: medicationController,
                    onChanged: (text) {
                      setState(() {

                        medicationInfo = text;
                      });

                    },
                  ),),

                space,
                ratingSliderWidget,
                space2,
                Slider(
                    value: _currentRating, // Use _currentRating here
                    onChanged: (double value) {
                      _updateRatingUI(value);
                    },
                    max: 100.0,
                    min: 0.0,
                    divisions: 100,
                    label: _currentRating.toStringAsFixed(1)), // Use _currentRating here
                space,
                //Media Tile
                GestureDetector(
                    onTap: () {
                      _showAlert(context, "Double tap will take you to the Picture selection screen");
                    },
                    onDoubleTap:(){
                  _pageController
                      .previousPage(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInExpo)
                      .whenComplete(() =>
                      setState(() {
                        currentPage = _pageController.page!;
                      })
                  );
                },
                    child:
                Card( borderOnForeground: true,
                    child:Column(spacing: 5, mainAxisAlignment: MainAxisAlignment.center,
                    children: [ space,
                  Row(children: [SizedBox(width:20),Expanded(child: Text("Did you like the picture you selected?"))]),
                  space,
                  Row(children: [ Expanded(child:
                  journalImage(swapper))
                  ])
                ])
               )),
                space,
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: SwitchListTile(
                      value: isChecked,
                      onChanged: (bool value) {
                        _updateSuccessUI(value);
                      },
                      title: successStateWidget,
                      activeColor: Color(swapper.isColorSeed),
                    )),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
            swapper),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsBloc = Provider.of<RecordsBloc>(context, listen: false);
    const pageCount = 13;
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: backArrowIcon,
            onPressed: () {
              recordsBloc.getRecords(false);
              Navigator.pop(context);
            },
          ),
          title: Text(super.widget.title),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/composehelp');
                },
                icon: const Icon(Icons.help))
          ],
        ),
        key: _formKey,
        body: SafeArea(
          minimum: const EdgeInsets.fromLTRB(15, 15, 15, 80),
          // Code to examine for ratings dashboard examination
          child: Stack(//fit:StackFit.expand,
            children: [

              currentPage! == 0
                  ? const Text("")
                  : Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: (){
                      _pageController
                          .previousPage(
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeInExpo)
                          .whenComplete(() =>
                          setState(() {
                            currentPage = _pageController.page!;
                          })
                      );

                    },
                    child: Container(alignment: Alignment.center,width: 30, height: double.infinity,
                      child: backArrowIcon,),
                  )
        ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(35, 8, 35, 50),
                  child: _buildJournalCards(swapper)),
              currentPage! == pageCount - 1
                  ? const Text("")
                  : Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: InkWell(
                    onTap: (){
                      _pageController
                          .nextPage(
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.easeIn).whenComplete(() => setState(() {
                        currentPage = _pageController.page!;
                      }));
                      },
                  child: Container(alignment: Alignment.center,width: 30, height: double.infinity,
                    child: nextArrowIcon,),

                  )
                //nextButton


              ),
              _buildPageIndicator(swapper, pageCount)
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            try {
              await _saveRecord(recordsBloc);
            } on Exception {
              _showAlert(context, "Save failed");
            }
          },
          label: const Text("Save"),
          icon: const Icon(Icons.save),
        ),
      );
    });
  }


  @override
  void dispose() {
    _debouncer.dispose();
    _symptomController.dispose();
    _contentController.dispose(); // Already here, ensure it's the one used for prediction
    titleController.dispose();
    emotionsController.dispose();
    sourceController.dispose();
    tagsController.dispose();
    _pageController.dispose();
    medicationController.dispose();
    controller?.dispose(); // Dispose camera controller if initialized
    super.dispose();
  }

  ///Saves the record in the database
  Future<void> _saveRecord(RecordsBloc recordsBloc) async {
    print("Medication is :"+medicationController.text);
    super.widget.record.timeUpdated = DateTime.now();
    if (customDate != super.widget.record.timeCreated) {
      super.widget.record.timeCreated = customDate;
    }
    super.widget.record.media = pictureBytes;
    super.widget.record.title = titleController.text;
    super.widget.record.content = contentController.text; // Use _contentController for saving
    super.widget.record.emotions = emotionsController.text;
    super.widget.record.sources = sourceController.text;
    super.widget.record.tags = tagsController.text;
    super.widget.record.sleep = sleepRating;
    super.widget.record.medication = medicationController.text;
    // Ensure these are also set for the record object being saved, if they are meant to persist
    super.widget.record.rating = _currentRating;

    //Test prediction logic
    if(_lastmodelprediction!=null){
      print("Calling learning function before saving...");
      await Global.personalizationService.learnFromCorrection(
        modelPrediction: _lastmodelprediction!,
        userProvidedSuccess: super.widget.record.success,
        record: super.widget.record,
      );
    }



   try{
     if (super.widget.id == 0) {
       await recordsBloc.addRecord(super.widget.record);

     } else {
       await recordsBloc.updateRecord(super.widget.record);

     }

     if(mounted){
       Navigator.pop(context, super.widget.record);
     }
   }

   catch(e){
     if(mounted){
       _showAlert(context, "Save failed");
       Navigator.pop(context);
     }
   }



  }

  //Loads an already existing record in the database
  void loadRecord() {
    print("Medication is :"+super.widget.record.medication);
    titleController.text = super.widget.record.title;
    contentController.text = super.widget.record.content; // Use _contentController for loading
    emotionsController.text = super.widget.record.emotions;
    sourceController.text = super.widget.record.sources;
    tagsController.text = super.widget.record.tags;
    symptomCoverText = super.widget.record.symptoms; // Or appropriate field for keywords
    medicationController.text = super.widget.record.medication;
    sleepRating = super.widget.record.sleep;
    _currentRating = super.widget.record.rating;

    if(super.widget.record.media!=Uint8List(0)) {
      pictureBytes=super.widget.record.media;
    } else {
      pictureBytes = Uint8List(0);
    }
    customDate = super.widget.record.timeCreated;
    setState(() {
      //Success Switch
      if (super.widget.record.success) {
        isChecked = true;
        successLabelText = 'Success';
        successStateWidget = Text(successLabelText);
      } else {
        isChecked = false;
        successLabelText = 'Fail';
        successStateWidget = Text(successLabelText);
      }
      // Picture
      pictureBytes = super.widget.record.media;
      //Custom date stamp
      customDate = super.widget.record.timeCreated;
      //Sleep Rating widget info
      if (super.widget.record.sleep == 100.0) {
        sleepInfo = "Sleep : Perfect ";
      } else if (super.widget.record.sleep >= 85.0 && super.widget.record.sleep < 100.0) {
        sleepInfo = 'Sleep : Great';
      } else if (super.widget.record.sleep >= 70.0 && super.widget.record.sleep < 85.0) {
        sleepInfo = 'Sleep : Good';
      } else if (super.widget.record.sleep >= 55.0 && super.widget.record.sleep < 70.0) {
        sleepInfo = 'Sleep : Okay';
      } else if (super.widget.record.sleep >= 40.0 && super.widget.record.sleep < 55.0) {
        sleepInfo = 'Sleep : Could be better';
      } else if (super.widget.record.sleep >= 25.0 && super.widget.record.sleep < 40.0) {
        sleepInfo = 'Sleep : Poor';
      } else if (super.widget.record.sleep < 25.0) {
        sleepInfo = 'Sleep : Little sleep';
      }

      //Rating slider widget info
      if (super.widget.record.rating == 100.0) {
        ratingInfo = "Rating : Perfect ";
      } else if (super.widget.record.rating >= 85.0 &&
          super.widget.record.rating < 100.0) {
        ratingInfo = 'Rating : Great';
      } else if (super.widget.record.rating >= 70.0 &&
          super.widget.record.rating < 85.0) {
        ratingInfo = 'Rating : Good';
      } else if (super.widget.record.rating >= 55.0 &&
          super.widget.record.rating < 70.0) {
        ratingInfo = 'Rating : Okay';
      } else if (super.widget.record.rating >= 40.0 &&
          super.widget.record.rating < 55.0) {
        ratingInfo = 'Rating : Could be better';
      } else if (super.widget.record.rating >= 25.0 &&
          super.widget.record.rating < 40.0) {
        ratingInfo = 'Rating : Not going well';
      } else if (super.widget.record.rating < 25.0) {
        ratingInfo = 'Rating : It\'s a mess';
      }
      ratingSliderWidget = Text(ratingInfo);
    });
  }

  void _showAlert(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
  }


  /// Image picker code, uses camera and gallery
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final imageBytes = await image.readAsBytes();
        setState(() {
          pictureBytes = imageBytes;
        });
      } else {
        print('No image selected');
      }
    } on Exception catch (e) {
      print("Image selection failed");
    }
  }


  ///Date Picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: customDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked == null) {
      return;
    }
    if (!context.mounted) return;
     TimeOfDay? pickedTime = TimeOfDay.fromDateTime(customDate);
     pickedTime = await showTimePicker(
      context: context,
      initialTime: pickedTime,
      helpText: 'Select time',
      builder: (BuildContext context, Widget? child){
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      }
    );
    if (picked != null ) {
      setState(() {
        customDate =DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime!.hour,
            pickedTime.minute,

        );
        super.widget.record.timeCreated = customDate;
      });
    }
  }
  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}


class RecordsScreenNotifier extends ChangeNotifier {
  final AdhdMlService _adhdMlService;

  RecordsScreenNotifier(this._adhdMlService) {
    // You can load initial data here if needed.
    // E.g., fetchRecords();
  }

  // --- STATE PROPERTIES ---

  /// The list of records to be displayed.
  List<Records> _records = [];
  List<Records> get records => _records;

  /// The current state of the prediction process.
  PredictionUiState _predictionState = PredictionIdle();
  PredictionUiState get predictionState => _predictionState;

  // --- BUSINESS LOGIC ---

  /// Runs a prediction for a given record by calling the ML service.
  Future<void> runPredictionForRecord(Records record) async {
    // Prevent starting a new prediction if one is already in progress.
    if (_predictionState is PredictionLoading) return;

    // 1. Set state to Loading and notify UI to update.
    _predictionState = PredictionLoading();
    notifyListeners();

    try {
      // 2. Call the asynchronous service method.
      final predictionResults = await _adhdMlService.predictRecord(record,); // Changed to predictRecord

      // 3. Update state based on the result.
      if (predictionResults.isNotEmpty) {
        _predictionState = PredictionSuccess(predictionResults);
      } else {
        _predictionState = PredictionError("Prediction returned no results.");
      }
    } catch (e) {
      _predictionState = PredictionError(e.toString());
    }

    // 4. Notify UI again with the final result (Success or Error).
    notifyListeners();
  }

  /// Resets the prediction state back to idle.
  void resetPredictionState() {
    _predictionState = PredictionIdle();
    notifyListeners();
  }
}
