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

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    contentController = TextEditingController();
    emotionsController = TextEditingController();

    if(super.widget.id==1)
      {
        loadRecord();
      }
    else{
      titleField = TextField(
        textCapitalization: TextCapitalization.words,
        controller: titleController, onChanged: (text) {
        super.widget.record.title = text;
      },);
      contentField =
          TextField(controller: contentController, onChanged: (text) {
            super.widget.record.content = text;
          },);
      emotionsField = TextField(
        controller: emotionsController,
        onChanged: (text){
          super.widget.record.emotions = text;
        },
      );
    }
  }


  void saveRecord() async {

    if(super.widget.record.title=='')
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

    titleField = TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: titleController, onChanged: (text) {
      super.widget.record.title = text;
    },
    );
    contentField = TextField(controller: contentController, onChanged: (text) {
      super.widget.record.content=text;
    },);
    emotionsField = TextField(
      controller: emotionsController,
      onChanged: (text){
        super.widget.record.emotions = text;
      },
    );
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
        const EdgeInsets.only(left: 80, top: 40, right: 80, bottom: 40),
          children:
          <Widget>[
            titleField,
            contentField,
            emotionsField,
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