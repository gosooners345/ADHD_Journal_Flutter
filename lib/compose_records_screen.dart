import 'package:flutter/foundation.dart';

import 'main.dart';
import 'package:flutter/material.dart';

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
  SizedBox space = SizedBox(height: 16);


  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    contentController = TextEditingController();
    emotionsController = TextEditingController();
    sourceController = TextEditingController();

    if(super.widget.id==1)
      {
        loadRecord();
      }
    else{
      titleField = TextField( decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'What do you want to call this?'),
        textCapitalization: TextCapitalization.words,
        controller: titleController, onChanged: (text) {
        super.widget.record.title = text;
      },);
      contentField =
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'What\'s on your mind? ',),
            controller: contentController, onChanged: (text) {
            super.widget.record.content = text;
          },);
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
    }
  }


  void saveRecord() async {

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

  void loadRecord() async {

    titleController.text = super.widget.record.title;
contentController.text=super.widget.record.content;
emotionsController.text=super.widget.record.emotions;
sourceController.text = super.widget.record.sources;

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