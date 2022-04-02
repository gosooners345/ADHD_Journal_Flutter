import 'package:flutter/foundation.dart';

import 'main.dart';
import 'package:flutter/material.dart';

import 'records_data_class_db.dart';
import 'recordsdatabase_handler.dart';





class ComposeRecordsWidget extends StatefulWidget{
  const ComposeRecordsWidget({Key? key, required this.id}) : super(key: key);

  final int id;

  @override
  State<ComposeRecordsWidget> createState() => _ComposeRecordsWidgetState();
}

class _ComposeRecordsWidgetState extends State<ComposeRecordsWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextField titleField;
  late TextEditingController titleController;
  late TextField contentField;
  late TextEditingController contentController;
  String titleText = '',
      contentText = '';
  int recID = 0;


  late Records newRecord;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController();
    contentController = TextEditingController();

    if (super.widget.id != records.length+1) {
      loadRecord(super.widget.id);
    } else {
      titleField = TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: titleController, onChanged: (text) {
        titleText = text;
      },
      );
      contentField =
          TextField(controller: contentController, onChanged: (text) {
            contentText = text;
          },);
    }
  }

  ///Placeholder method
  void saveRecord() async {
    if (super.widget.id != 0) {
      recID = super.widget.id;
    } else {
      recID = records.length + 1;
    }
    newRecord = Records(id: recID, title: titleText, content: contentText);
    try {
      RecordsDB.insertRecord(newRecord);
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
    records = await RecordsDB.records();
    Navigator.pop(context);
  }

  void loadRecord(int id) async {
    Records record = records.firstWhere((element) => element.id == id);
    titleController.text = record.title;
contentController.text=record.content;

    titleField = TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: titleController, onChanged: (text) {
      titleText = text;
    },
    );
    contentField = TextField(controller: contentController, onChanged: (text) {
      contentText = text;
    },);
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