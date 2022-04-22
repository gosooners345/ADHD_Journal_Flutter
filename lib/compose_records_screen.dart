import 'package:flutter/foundation.dart';

import 'main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'records_data_class_db.dart';
import 'recordsdatabase_handler.dart';





class ComposeRecordsWidget extends StatefulWidget{
  const ComposeRecordsWidget({Key? key, required this.record,required this.id}) : super(key: key);
 final Records record;

  final int id;

  @override
  State<ComposeRecordsWidget> createState() => _ComposeRecordsWidgetState();
}

class _ComposeRecordsWidgetState extends State<ComposeRecordsWidget> {
  final _formKey = GlobalKey<_ComposeRecordsWidgetState>();




  late TextField titleField;
  late TextEditingController titleController;
  late TextField contentField;
  late TextEditingController contentController;
  late TextField emotionsField;
  late TextEditingController emotionsController;
  late TextField sourcesField;
  late TextEditingController sourceController;
  late TextField symptomField;
  late TextEditingController symptomController;
  late TextField tagsField;
  late TextEditingController tagsController;

  double ratingValue = 0.0;
  bool successState = false;
  bool isChecked = false;
late SwitchListTile successSwitch ;
Text successStateWidget = Text('');
 String successLabelText = '';
  SizedBox space = const SizedBox(height: 16);


  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    contentController = TextEditingController();
    emotionsController = TextEditingController();
    sourceController = TextEditingController();
symptomController = TextEditingController();
tagsController = TextEditingController();

    if(super.widget.id==1){
        // Load an existing record
        loadRecord();
      }
    else{
      //Title Field
      titleField = TextField( decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'What do you want to call this?'),
        textCapitalization: TextCapitalization.words,
        controller: titleController, onChanged: (text) {
        super.widget.record.title = text;
      },);
      //Content Field
      contentField = TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'What\'s on your mind? ',),
            controller: contentController, onChanged: (text) {
            super.widget.record.content = text;
          },);
      //Emotions field
      emotionsField = TextField(
 decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'How do you feel today?',
        ),
        controller: emotionsController,
        onChanged: (text){
          super.widget.record.emotions = text;
        },
      );
      //Sources Field
      sourcesField = TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Do you have anything to add to this?',),
        controller: sourceController,
        onChanged: (text){
          super.widget.record.sources = text;
        },
        textCapitalization: TextCapitalization.sentences,
      );
      //Symptom field
      symptomField = TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Related ADHD Symptoms ',),
        controller:symptomController , onChanged: (text) {
        super.widget.record.symptoms= text;
      },);
      //Tags Field
      tagsField = TextField(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'What does this fall under?',),
        controller:tagsController, onChanged: (text) {
        super.widget.record.tags= text;
      },);
      //Success Switch
      successLabelText = 'Success/Fail';
      successStateWidget = Text(successLabelText);


    }
  }

//Saves the record in the database
  void saveRecord() async {
    super.widget.record.timeUpdated = DateFormat('MM/dd/yyyy kk:mm').format(DateTime.now().toLocal());
    if(super.widget.id==0)
      {
        RecordsDB.insertRecord(super.widget.record);
        records.add(super.widget.record);
      }
    else {
      RecordsDB.updateRecords(super.widget.record);
    }
    Navigator.pop(context,super.widget.record);
  }
  //Loads an already existing record in the database
  void loadRecord() async {

    titleController.text = super.widget.record.title;
contentController.text=super.widget.record.content;
emotionsController.text=super.widget.record.emotions;
sourceController.text = super.widget.record.sources;
symptomController.text = super.widget.record.symptoms;
tagsController.text = super.widget.record.tags;

    setState(() {
if (super.widget.record.success == 'success'){
  successLabelText = 'Success';
  successStateWidget = Text(successLabelText);
}
else{
  successLabelText = 'Fail';
  successStateWidget = Text(successLabelText);
}

    });


    titleField = TextField( decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'What do you want to call this?'),
      textCapitalization: TextCapitalization.sentences,
      controller: titleController, onChanged: (text) {
      super.widget.record.title = text;
    },
    );
    contentField = TextField(
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'What\'s on your mind? ',),
      textCapitalization: TextCapitalization.sentences,controller: contentController, onChanged: (text) {
      super.widget.record.content=text;
    },);
    emotionsField = TextField( decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'How do you feel today?',
        ),
      controller: emotionsController,
      onChanged: (text){
        super.widget.record.emotions = text;
      },
    );
    sourcesField = TextField( decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Do you have anything to add to this?',),
      textCapitalization: TextCapitalization.sentences,
      controller: sourceController, onChanged: (text) {
      super.widget.record.sources = text;
    },    );
    symptomField = TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Related ADHD Symptoms ',),
      controller:symptomController , onChanged: (text) {
      super.widget.record.symptoms= text;
    },);
    //Tags Field
    tagsField = TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'What does this fall under?',),
      controller:tagsController, onChanged: (text) {
      super.widget.record.tags= text;
    },);
    //Success Switch
    successLabelText = 'Success/Fail';
    successStateWidget = Text(successLabelText);





  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compose New Record'),
      ),
      key: _formKey,
      body: Center(
        child: ListView(padding:
        const EdgeInsets.only(left: 8, top: 40, right: 8, bottom: 40),
          children:
          <Widget>[
            titleField,
            space,
            contentField,
            space,
            emotionsField,
            space,
            sourcesField,
            space,
            symptomField,
            space,
            tagsField,
            space,
          Slider(value: super.widget.record.rating, onChanged: (double value) {
            setState(() {super.widget.record.rating = value;});},max: 100.0,min: 0.0,
              divisions: 100,label:super.widget.record.rating.toString()
          ),
            space,
            SwitchListTile(value: isChecked, onChanged: (bool value){
              super.widget.record.success = value ? 'Success':'Fail';
              isChecked = value;
              setState(() {
                if(value){
                  successLabelText = 'Success';
                  successStateWidget = Text(successLabelText);
                }
                else{
                  successLabelText = 'Fail';
                  successStateWidget = Text(successLabelText);
                }
              });
            },
              title: successStateWidget,
            )
,
            space,
            ElevatedButton(
              onPressed: () {
                saveRecord();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }


}