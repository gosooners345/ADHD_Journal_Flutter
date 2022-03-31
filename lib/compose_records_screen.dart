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
late Records newRecord ;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
return Form(
  key: _formKey,
    child: Column(
      children: <Widget>[
        TextFormField(
          // The validator receives the text that the user has entered.
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        TextFormField(
          // The validator receives the text that the user has entered.
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter some text';
            }
            return null;
          },
        ),
        ElevatedButton(
          onPressed: () {
            // Validate returns true if the form is valid, or false otherwise.
            if (_formKey.currentState!.validate()) {
              // If the form is valid, display a snackbar. In the real world,
              // you'd often call a server or save the information in a database.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing Data')),
              );
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