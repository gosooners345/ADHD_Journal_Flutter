import 'package:adhd_journal_flutter/main.dart';
import 'package:flutter/material.dart';

import 'records_data_class_db.dart';
import 'recordsdatabase_handler.dart';


class ComposeRecords extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Compose Records',
      home: Scaffold(
        appBar: AppBar(title: const Text('Compose New Record'),),
        body: const ComposeRecordsWidget(),
      ),
    );

  }

}


class ComposeRecordsWidget extends StatefulWidget{
  const ComposeRecordsWidget({Key? key}) : super(key: key);


  @override
  State<ComposeRecordsWidget> createState() => _ComposeRecordsWidgetState();
}

class _ComposeRecordsWidgetState extends State<ComposeRecordsWidget>{
  final _formKey = GlobalKey<FormState>();
  late TextField titleField;
  late TextField contentField;
  String titleContent ='',contentText='';



//late Records newRecord ;

  @override
  void initState() {
    super.initState();
  }

  ///Placeholder method
void saveRecord() async{


  }

  @override
  Widget build(BuildContext context) {
return Form(
  key: _formKey,
    child: Column(
      children: <Widget>[
        TextField(onChanged: (text) {
          titleContent = text;
        },)
        ,
        TextField(onChanged: (text){
          contentText = text;
        },),
        ElevatedButton(
          onPressed: () {
            // Validate returns true if the form is valid, or false otherwise.


              //Navigator.push(context,MaterialPageRoute(builder: (context) => const MyHomePage(title: 'ADHD Journal')));
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
);

  }



}