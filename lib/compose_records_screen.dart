import 'dart:async';

import 'package:adhd_journal_flutter/project_colors.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'symptom_selector_screen.dart';
import 'records_data_class_db.dart';


class ComposeRecordsWidget extends StatefulWidget {
  const ComposeRecordsWidget(
      {Key? key, required this.record, required this.id, required this.title})
      : super(key: key);
  final Records record;
  final String title;
  final int id;

  @override
  State<ComposeRecordsWidget> createState() => _ComposeRecordsWidgetState();
}

class _ComposeRecordsWidgetState extends State<ComposeRecordsWidget> {
  final _formKey = GlobalKey<_ComposeRecordsWidgetState>();

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
  Text successStateWidget = Text('');
  String successLabelText = '';
  SizedBox space = const SizedBox(height: 16);
  SizedBox space2 = const SizedBox(height: 8);
  Text ratingSliderWidget = Text('');
  String ratingInfo = '';

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


  void addRecord() async{
    recordsBloc.addRecord(super.widget.record);
  }
  void updateRecord() async{
    recordsBloc.updateRecord(super.widget.record);
  }

  quickTimer() async {
    var duration = const Duration(milliseconds: 2);
    return Timer(duration,addRecord);
  }
  updateTimer() async{
    return Timer(const Duration(milliseconds: 2),updateRecord);
  }



//Saves the record in the database
  void saveRecord(Records record) async {
     record.timeUpdated = DateTime.now();
    if (super.widget.id == 0) {
  quickTimer();
     }
    else {
      updateTimer();
    }
     recordHolder= recordsBloc.recordHolder;
    print(recordHolder.length);


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
    return Scaffold(
      appBar: AppBar(
        title: Text(super.widget.title),
      ),
      key: _formKey,
      body: Center(
        child: ListView(
          padding:
              const EdgeInsets.only(left: 8, top: 40, right: 8, bottom: 40),
          children: <Widget>[
            //Title Field
            TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                          color: Colors.brown.withOpacity(1.0), width: 1)),
                  labelText: 'What do you want to call this?'),
              textCapitalization: TextCapitalization.sentences,
              controller: titleController,
              onChanged: (text) {
                super.widget.record.title = text;
              },
            ),
            space,
            //Content Field
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: Colors.brown.withOpacity(1.0), width: 1)),
                labelText: 'What\'s on your mind? ',
              ),
              textCapitalization: TextCapitalization.sentences,
              controller: contentController,
              onChanged: (text) {
                super.widget.record.content = text;
              },
            ),
            space,
            //Emotions Field
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: Colors.brown.withOpacity(1.0), width: 1)),
                labelText: 'How do you feel today?',
              ),
              controller: emotionsController,
              onChanged: (text) {
                super.widget.record.emotions = text;
              },
            ),
            space,
            //Source Field
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: Colors.brown.withOpacity(1.0), width: 1)),
                labelText: 'Do you have anything to add to this?',
              ),
              textCapitalization: TextCapitalization.sentences,
              controller: sourceController,
              onChanged: (text) {
                super.widget.record.sources = text;
              },
            ),
            space,
            //Symptom Field,
            Card(
              borderOnForeground: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // if you need this
                side: BorderSide(
                  color: Colors.red.withOpacity(1.0),
                  width: 1,
                ),
              ),
              child: ListTile(
                title: Text(
                    'Related ADHD Symptoms: \r\n${super.widget.record.symptoms}'),
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
            ),
            space,
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(
                        color: AppColors.mainAppColor.withOpacity(1.0), width: 1)
                ),
                labelText: 'What does this fall under?',
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
              title: successStateWidget,activeColor: AppColors.mainAppColor,
            ),
            space,
            ElevatedButton(
              onPressed: () {
                saveRecord(super.widget.record);
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
