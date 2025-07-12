import 'dart:async';
import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import '../project_resources/project_utils.dart';
import 'symptom_selector_screen.dart';
import '../record_data_package/records_data_class_db.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:image_picker/image_picker.dart';



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
  double? currentPage = 0;
  //double ratingValue = 0.0;
 // bool successState = false;
  bool isChecked = false;
  Text successStateWidget = const Text('');
  String successLabelText = '';
  SizedBox space = const SizedBox(height: 16);
  SizedBox space2 = const SizedBox(height: 8);
  Text ratingSliderWidget = const Text('');
  Uint8List pictureBytes = Uint8List(0);
  ImagePicker picker = ImagePicker();
  ByteData data = ByteData(0);
  String ratingInfo = '';
  String symptomCoverText = "Tap here to add Symptoms";


  late RecordsBloc _recordsBloc;
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
    contentController = TextEditingController();
    emotionsController = TextEditingController();
    sourceController = TextEditingController();
    tagsController = TextEditingController();
///Loading existing record code
    if (super.widget.id == 1) {
      // Load an existing record
      loadRecord();
    } else {
      ratingInfo = 'Rating :';
      ratingSliderWidget = Text(ratingInfo);
      //Success Switch
      successLabelText = 'Success/Fail';
      successStateWidget = Text(successLabelText);
    }
    _updateRatingUI(super.widget.record.rating);
    _updateSuccessUI(super.widget.record.success);

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


///UI Updating code
  void _updateRatingUI (double newRating){
    super.widget.record.rating = newRating;
   // super.widget.record.rating = value;

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
        ///When the event took place if not recently
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

        /// Title
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
                  },
                ),
              ),
            ]),
            swapper),

        /// What happened
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
                    controller: contentController,
                    onChanged: (text) {
                      super.widget.record.content = text;
                    },
                  )),
              space
            ]),
            swapper),

        /// Emotions
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
                      },
                    )),
              ],
            ),
            swapper),

        /// Surrounding Circumstances
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
                      },
                    )),
                space
              ],
            ),
            swapper),

        /// Related ADHD Symptoms
        GestureDetector(
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
              }).onError((error, stackTrace) {
                super.widget.record.symptoms = '';
              });
            },
            child: uiCard(

                Column(
                    crossAxisAlignment: CrossAxisAlignment.center, children: [
                  const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "Related ADHD Symptoms:" "\r\n ",
                        style: TextStyle(fontSize: 20),
                      )),
                  ListTile(
                    title: super.widget.record.symptoms == ""
                        ? Text(symptomCoverText)
                        : Text(
                      super.widget.record.symptoms,
                      style: const TextStyle(fontSize: 15),
                    ),
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
                      }).onError((error, stackTrace) {
                        super.widget.record.symptoms = '';
                      });
                    },
                  ),
                  space
                ]),
                swapper)),

///Event Tags
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
                      },
                    )),
              ],
            ),
            swapper),

        /// Rating: How it went
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
                    value: super.widget.record.rating,
                    onChanged: (double value) {
                      _updateRatingUI(value);
                    },
                    max: 100.0,
                    min: 0.0,
                    divisions: 100,
                    label: super.widget.record.rating.toString()),
              ],
            ),
            swapper),

        /// Success/Fail
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
                   /* super.widget.record.success = value;
                    isChecked = value;
                    setState(() {
                      if (value) {
                        successLabelText = 'Success';
                        successStateWidget = Text(successLabelText);
                      } else {
                        successLabelText = 'Fail';
                        successStateWidget = Text(successLabelText);
                      }
                    });*/
                    _updateSuccessUI(value);
                  },
                  title: successStateWidget,
                  activeColor: Color(swapper.isColorSeed),
                ),
              )
            ]),
            swapper),

        ///Add Pictures or other media here
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

        ///Entry Review
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
                  controller: contentController,
                  onChanged: (text) {
                    super.widget.record.content = text;
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
                  },
                ), //x
                space,
                //Symptom Field,
                Card(
                  borderOnForeground: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4), // if you need this
                    side: BorderSide(
                      color: Color(swapper.isColorSeed).withOpacity(1.0),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                        'Related ADHD Symptoms: \r\n${super.widget.record
                            .symptoms == '' ? symptomCoverText : super.widget
                            .record.symptoms}'),
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
                      });
                    },
                  ),
                ), //x
                space,
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
                  },
                ),
                space,
                ratingSliderWidget,
                space2,
                Slider(
                    value: super.widget.record.rating,
                    onChanged: (double value) {
                      setState(() {
                        super.widget.record.rating = value;

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
                    },
                    max: 100.0,
                    min: 0.0,
                    divisions: 100,
                    label: super.widget.record.rating.toString()),
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
                        super.widget.record.success = value;
                        isChecked = value;
                        setState(() {
                          if (value) {
                            successLabelText = 'Success';
                            successStateWidget = Text(successLabelText);
                          } else {
                            successLabelText = 'Fail';
                            successStateWidget = Text(successLabelText);
                          }
                        });
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
    const pageCount = 11;
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: backArrowIcon,
            onPressed: () {
              recordsBloc.getRecords();
              Navigator.pop(context);
              //_saveRecord(super.widget.record);
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
    titleController.dispose();
    contentController.dispose();
    emotionsController.dispose();
    sourceController.dispose();
    tagsController.dispose();
    _pageController.dispose();
    controller?.dispose(); // Dispose camera controller if initialized
    super.dispose();
  }
 /* void addRecord() async {
    _recordsBloc.addRecord(super.widget.record);
  }

  void updateRecord() async {
    _recordsBloc.updateRecord(super.widget.record);
  }

  quickTimer() async {
    var duration = const Duration(milliseconds: 2);
    return Timer(duration, addRecord);
  }

  updateTimer() async {
    return Timer(const Duration(milliseconds: 2), updateRecord);
  }*/
  ///Saves the record in the database
  Future<void> _saveRecord(RecordsBloc recordsBloc) async {
    super.widget.record.timeUpdated = DateTime.now();
    if (customDate != super.widget.record.timeCreated) {
      super.widget.record.timeCreated = customDate;
    }
    super.widget.record.media = pictureBytes;
    super.widget.record.title = titleController.text;
    super.widget.record.content = contentController.text;
    super.widget.record.emotions = emotionsController.text;
    super.widget.record.sources = sourceController.text;
    super.widget.record.tags = tagsController.text;
   try{
     if (super.widget.id == 0) {
       await recordsBloc.addRecord(super.widget.record);
       //addRecord();
        //quickTimer();
     } else {
       await recordsBloc.updateRecord(super.widget.record);
       // updateTimer();
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
    titleController.text = super.widget.record.title;
    contentController.text = super.widget.record.content;
    emotionsController.text = super.widget.record.emotions;
    sourceController.text = super.widget.record.sources;
    tagsController.text = super.widget.record.tags;
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

}
