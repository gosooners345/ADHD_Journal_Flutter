import 'dart:async';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:adhd_journal_flutter/records_compose_components/compose_records_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import 'symptom_selector_screen.dart';
import '../record_data_package/records_data_class_db.dart';
// This is for testing a new style of journal entry. This may break functionality or improve it.
import 'package:intro_screen_onboarding_flutter/circle_progress_bar.dart';
import 'package:intro_screen_onboarding_flutter/intro_app.dart';
import '../ui_components/introduction_modified.dart' as Intro;
import '../ui_components/introscreenBoardingModified.dart' as IntroBoarding;

class NewComposeRecordsWidget extends StatefulWidget {
  const NewComposeRecordsWidget(
      {Key? key, required this.record, required this.id, required this.title})
      : super(key: key);
  final Records record;
  final String title;
  final int id;

  @override
  State<NewComposeRecordsWidget> createState() => _NewComposeRecordsWidgetState();
}

class _NewComposeRecordsWidgetState extends State<NewComposeRecordsWidget> {
  final _formKey = GlobalKey<_NewComposeRecordsWidgetState>();

  // Text Controllers for views to contain data from loading in the record or storing data

  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController emotionsController;
  late TextEditingController sourceController;
  late TextEditingController tagsController;
  late SwitchListTile successSwitch;
  double ratingValue = 0.0;
  bool successState = false;
  bool isChecked = false;
  Text successStateWidget = const Text('');
  String successLabelText = '';
  SizedBox space = const SizedBox(height: 16);
  SizedBox space2 = const SizedBox(height: 8);
  Text ratingSliderWidget = const Text('');
  String ratingInfo = '';
String symptomCoverText = "Tap here to add Symptoms";
  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    contentController = TextEditingController();
    emotionsController = TextEditingController();
    sourceController = TextEditingController();
    tagsController = TextEditingController();

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
  }

  void addRecord() async {
    recordsBloc.addRecord(super.widget.record);
  }

  void updateRecord() async {
    recordsBloc.updateRecord(super.widget.record);
  }

  quickTimer() async {
    var duration = const Duration(milliseconds: 2);
    return Timer(duration, addRecord);
  }

  updateTimer() async {
    return Timer(const Duration(milliseconds: 2), updateRecord);
  }

//Saves the record in the database
  void saveRecord(Records record) async {
    record.timeUpdated = DateTime.now();
    if (super.widget.id == 0) {
      quickTimer();
    } else {
      updateTimer();
    }

    if (kDebugMode) {
      print(listSize);
    }
    Navigator.pop(context, super.widget.record);
  }

  //Loads an already existing record in the database
  void loadRecord() {
    titleController.text = super.widget.record.title;
    contentController.text = super.widget.record.content;
    emotionsController.text = super.widget.record.emotions;
    sourceController.text = super.widget.record.sources;
    tagsController.text = super.widget.record.tags;

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

  @override
  Widget build(BuildContext context) {

    final PageController controller = PageController();
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: backArrowIcon,
            onPressed: () {
              saveRecord(super.widget.record);
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
        body:
PageView(
  controller: controller,
  children: [
    SizedBox(height: 150,child:/*Expanded(
        child:*/Card(borderOnForeground: true,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(4), // if you need this
    side: BorderSide(
      color: Color(colorSeed).withOpacity(1.0),
      width: 1,
    ),
  ),
  surfaceTintColor: Color(swapper.isColorSeed),
  child: ListView(shrinkWrap:true,padding: EdgeInsets.all(10),
      children:[
        const Center(child:Text("What do you want to call this?",style: TextStyle(fontSize: 20))),
        space,
        TextField(decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                  color: Color(colorSeed).withOpacity(1.0),
                  width: 1)),
          // labelText: 'What do you want to call this?'
        ),
          textCapitalization: TextCapitalization.sentences,
          controller: titleController,
          onChanged: (text) {
            super.widget.record.title = text;
          },
        ),
      ]),
)),//),),
    SizedBox(height: 150,child:/*Expanded(flex:1,child:*/  Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // if you need this
        side: BorderSide(
          color: Color(colorSeed).withOpacity(1.0),
          width: 1,
        ),
      ),
      elevation: 2.0,margin: const EdgeInsets.all(10),child:ListView(padding: const EdgeInsets.all(10.0),children: [
      const Center(child:Text("What\'s on your mind?",style: TextStyle(fontSize: 20) ,)),
      SizedBox(height: 3,),
      TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(
                  color: Color(swapper.isColorSeed).withOpacity(1.0),
                  width: 1)), //labelText: 'What\'s on your mind? ',
        ),
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        controller: contentController,
        onChanged: (text) {
          super.widget.record.content = text;
        },
      ),space
    ],)
      ,)
      ,),
    SizedBox(height: 150,child:Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // if you need this
        side: BorderSide(
          color: Color(colorSeed).withOpacity(1.0),
          width: 1,
        ),
      ),
      margin:const EdgeInsets.all(10),child: ListView(padding:const EdgeInsets.all(8.0),shrinkWrap: true,children: [const Center(
          child:Text("How do you feel currently?",style: TextStyle(fontSize: 20))),space,
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: Color(swapper.isColorSeed).withOpacity(1.0),
                      width: 1)),
              /*labelText: 'How do you feel today?',*/
              hintText: "Enter how you're feeling here."          ),
          controller: emotionsController,
          onChanged: (text) {
            super.widget.record.emotions = text;
          },
        ),],),),),
    SizedBox( height: 180,child:
    Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // if you need this
        side: BorderSide(
          color: Color(colorSeed).withOpacity(1.0),
          width: 1,
        ),
      ),
      margin:const EdgeInsets.all(10),child:ListView(padding:const EdgeInsets.all(8.0) ,children:[
        const Center(child:Text("Is there anything that may have contributed to this?",style: TextStyle(fontSize: 20.0))),
        space,
        TextField(
          decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: AppColors.mainAppColor.withOpacity(1.0),
                      width: 1)),
              labelText: 'This is where stuff like preexisting triggers, preliminary events, etc. can go.',
              hintText:
              'Add your thoughts or what you think could\'ve triggered this here'),
          keyboardType: TextInputType.multiline,
          minLines: 1,scrollController: ScrollController(),
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          controller: sourceController,
          onChanged: (text) {
            super.widget.record.sources = text;
          },),
        space],
      ),
    ),
    ),Card(
      borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // if you need this
        side: BorderSide(
          color: Color(colorSeed).withOpacity(1.0),
          width: 1,
        ),
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.center,children: [ Padding(padding: EdgeInsets.all(8.0),child:Text("Related ADHD Symptoms:"+
          "\r\n ",style: TextStyle(fontSize: 20),)),
        ListTile(

          title:super.widget.record.symptoms==""?Text(symptomCoverText): Text(super.widget.record.symptoms,style: TextStyle(fontSize: 15),),

          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => SymptomSelectorScreen(
                      symptoms: super.widget.record.symptoms,
                    ))).then((value) {
              setState(() {
                super.widget.record.symptoms = value as String;
              });
            }).onError((error, stackTrace)  {

              super.widget.record.symptoms='';});
          },
        ),space]),
    ),
          SizedBox(height:150,child:
          Card(borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // if you need this
                side: BorderSide(
                  color: Color(colorSeed).withOpacity(1.0),
                  width: 1,
                ),
              ),
              child:  ListView(
                padding: const EdgeInsets.all(8),
                children: [ const Center(child: Text("Tags",style: TextStyle(fontSize: 20),),),space, TextField(
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
                ),         ],)),),
    SizedBox(height:150,child:Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // if you need this
        side: BorderSide(
          color: Color(colorSeed).withOpacity(1.0),
          width: 1,
        ),
      ),child: ListView (padding: EdgeInsets.all(8),children: [
        const Center(child: Text("How would you rate this?",style: TextStyle(fontSize: 20),),),
        Center(child:ratingSliderWidget),Slider(
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
            label: super.widget.record.rating.toString()),],),),),
    SizedBox(height:150,child:Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // if you need this
        side: BorderSide(
          color: Color(colorSeed).withOpacity(1.0),
          width: 1,
        ),
      ),child:ListView(padding: EdgeInsets.all(8.0),children: [const Center(child:Text("Do you think what happened was successful? ",style: TextStyle(fontSize: 20))),SwitchListTile(
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
      ) ,]),),),
        Expanded(child:Card(
          borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // if you need this
            side: BorderSide(
              color: Color(colorSeed).withOpacity(1.0),
              width: 1,
            ),
          ),
          child:
          ListView(
            padding:
            const EdgeInsets.only(left: 8, top: 20, right: 8, bottom: 40),
            children: <Widget>[
              const Text("Here's what you entered. Check and see if everything is correct. Once you're done, hit save.",style:TextStyle(fontSize: 20)),space,
              //Title Field
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: Color(swapper.isColorSeed).withOpacity(1.0),
                            width: 1)),
                    labelText: 'What do you want to call this?'),
                textCapitalization: TextCapitalization.sentences,
                controller: titleController,
                onChanged: (text) {
                  super.widget.record.title = text;
                },
              ), //x
              space,
              //Content Field
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
              ),//x
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
                child:
                ListTile(
                  title: Text(
                      'Related ADHD Symptoms: \r\n${super.widget.record.symptoms == '' ? symptomCoverText : super.widget.record.symptoms }'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SymptomSelectorScreen(
                              symptoms: super.widget.record.symptoms,
                            ))).then((value) {
                      setState(() {
                        super.widget.record.symptoms = value as String;
                      });
                    });
                  },
                ),
              ),//x
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
              SwitchListTile(
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
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),),),
      ],

),
        /*IntroBoarding.IntroScreenOnboarding(
        onTapSkipButton: (){saveRecord(super.widget.record);},
          introductionList:
        
        [
          Intro.Introduction(childWidget:SizedBox(height: 150,child:*//*Expanded(
        child:*//*Card(borderOnForeground: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4), // if you need this
            side: BorderSide(
              color: Color(colorSeed).withOpacity(1.0),
              width: 1,
            ),
          ),
          surfaceTintColor: Color(swapper.isColorSeed),
          child: ListView(shrinkWrap:true,padding: EdgeInsets.all(10),
            children:[
              const Center(child:Text("What do you want to call this?",style: TextStyle(fontSize: 20))),
             space,
             TextField(decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                          color: Color(colorSeed).withOpacity(1.0),
                          width: 1)),
                 // labelText: 'What do you want to call this?'
              ),
              textCapitalization: TextCapitalization.sentences,
              controller: titleController,
              onChanged: (text) {
                super.widget.record.title = text;
              },
            ),
          ]),
        )),),//),
          Intro.Introduction(childWidget:
          SizedBox(height: 150,child:*//*Expanded(flex:1,child:*//*  Card(
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // if you need this
              side: BorderSide(
                color: Color(colorSeed).withOpacity(1.0),
                width: 1,
              ),
            ),
            elevation: 2.0,margin: const EdgeInsets.all(10),child:ListView(padding: const EdgeInsets.all(10.0),children: [
            const Center(child:Text("What\'s on your mind?",style: TextStyle(fontSize: 20) ,)),
SizedBox(height: 3,),
            TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(
                      color: Color(swapper.isColorSeed).withOpacity(1.0),
                      width: 1)), //labelText: 'What\'s on your mind? ',
            ),
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            controller: contentController,
            onChanged: (text) {
              super.widget.record.content = text;
            },
          ),space
            ],)
            ,)
            ,)
            ,//)
          ),
          Intro.Introduction(childWidget:
*//*        Expanded(flex:1 ,*//*SizedBox(height: 150,child:Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4), // if you need this
      side: BorderSide(
      color: Color(colorSeed).withOpacity(1.0),
      width: 1,
      ),
      ),
            margin:const EdgeInsets.all(10),child: ListView(padding:const EdgeInsets.all(8.0),shrinkWrap: true,children: [const Center(
            child:Text("How do you feel currently?",style: TextStyle(fontSize: 20))),space,
          TextField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: BorderSide(
                    color: Color(swapper.isColorSeed).withOpacity(1.0),
                    width: 1)),
           *//*labelText: 'How do you feel today?',*//*
hintText: "Enter how you're feeling here."          ),
          controller: emotionsController,
          onChanged: (text) {
            super.widget.record.emotions = text;
          },
        ),],),),),),
          Intro.Introduction(childWidget:
          *//*Expanded(flex:1,*//*
      SizedBox( height: 180,child:
      Card(borderOnForeground: true,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4), // if you need this
      side: BorderSide(
      color: Color(colorSeed).withOpacity(1.0),
      width: 1,
      ),
      ),
        margin:const EdgeInsets.all(10),child:ListView(padding:const EdgeInsets.all(8.0) ,children:[
        const Center(child:Text("Is there anything that may have contributed to this?",style: TextStyle(fontSize: 20.0))),
     space,
          TextField(
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: AppColors.mainAppColor.withOpacity(1.0),
                        width: 1)),
                  labelText: 'This is where stuff like preexisting triggers, preliminary events, etc. can go.',
                hintText:
                'Add your thoughts or what you think could\'ve triggered this here'),
            keyboardType: TextInputType.multiline,
            minLines: 1,scrollController: ScrollController(),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
            controller: sourceController,
            onChanged: (text) {
              super.widget.record.sources = text;
            },),
       space],
        ),
      ),
          ),
          ),
          Intro.Introduction(childWidget:
          Card(
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // if you need this
              side: BorderSide(
                color: Color(colorSeed).withOpacity(1.0),
                width: 1,
              ),
            ),
            child:Column(crossAxisAlignment:CrossAxisAlignment.center,children: [ Padding(padding: EdgeInsets.all(8.0),child:Text("Related ADHD Symptoms:"+
                "\r\n ",style: TextStyle(fontSize: 20),)),
              ListTile(

              title:super.widget.record.symptoms==""?Text(symptomCoverText): Text(super.widget.record.symptoms,style: TextStyle(fontSize: 15),),

              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => SymptomSelectorScreen(
                          symptoms: super.widget.record.symptoms,
                        ))).then((value) {
                  setState(() {
                    super.widget.record.symptoms = value as String;
                  });
                }).onError((error, stackTrace)  {

                   super.widget.record.symptoms='';});
              },
            ),space]),
          ),),
          Intro.Introduction(childWidget:
          SizedBox(height:150,child:
          Card(borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // if you need this
                side: BorderSide(
                  color: Color(colorSeed).withOpacity(1.0),
                  width: 1,
                ),
              ),
            child:  ListView(
              padding: const EdgeInsets.all(8),
              children: [ const Center(child: Text("Tags",style: TextStyle(fontSize: 20),),),space, TextField(
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
            ),         ],)),)),
          Intro.Introduction(childWidget:SizedBox(height:150,child:Card(borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // if you need this
              side: BorderSide(
                color: Color(colorSeed).withOpacity(1.0),
                width: 1,
              ),
            ),child: ListView (padding: EdgeInsets.all(8),children: [
            const Center(child: Text("How would you rate this?",style: TextStyle(fontSize: 20),),),
      Center(child:ratingSliderWidget),Slider(
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
      label: super.widget.record.rating.toString()),],),),),),

          Intro.Introduction(childWidget:
          SizedBox(height:150,child:Card(borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // if you need this
                side: BorderSide(
                  color: Color(colorSeed).withOpacity(1.0),
                  width: 1,
                ),
              ),child:ListView(padding: EdgeInsets.all(8.0),children: [const Center(child:Text("Do you think what happened was successful? ",style: TextStyle(fontSize: 20))),SwitchListTile(
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
          ) ,]),),),),
          Intro.Introduction(childWidget:
          Expanded(child:Card(
            borderOnForeground: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4), // if you need this
              side: BorderSide(
                color: Color(colorSeed).withOpacity(1.0),
                width: 1,
              ),
            ),
            child:
          ListView(
            padding:
            const EdgeInsets.only(left: 8, top: 20, right: 8, bottom: 40),
            children: <Widget>[
              const Text("Here's what you entered. Check and see if everything is correct. Once you're done, hit save.",style:TextStyle(fontSize: 20)),space,
              //Title Field
              TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide(
                            color: Color(swapper.isColorSeed).withOpacity(1.0),
                            width: 1)),
                    labelText: 'What do you want to call this?'),
                textCapitalization: TextCapitalization.sentences,
                controller: titleController,
                onChanged: (text) {
                  super.widget.record.title = text;
                },
              ), //x
              space,
              //Content Field
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
              ),//x
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
                child:
                  ListTile(
                  title: Text(
                      'Related ADHD Symptoms: \r\n${super.widget.record.symptoms == '' ? symptomCoverText : super.widget.record.symptoms }'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => SymptomSelectorScreen(
                              symptoms: super.widget.record.symptoms,
                            ))).then((value) {
                      setState(() {
                        super.widget.record.symptoms = value as String;
                      });
                    });
                  },
                ),
              ),//x
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
              SwitchListTile(
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
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),),),),
        ],),*/
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            try {
              saveRecord(super.widget.record);
            } on Exception {
              _showAlert(context, "Save failed");
            }
          },
          label: Text("Save"),
          icon: Icon(Icons.save),
        ),
      );
    });
  }






  void _showAlert(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
  }
}
