
import 'dart:async';
import 'dart:ffi';

import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_list_class.dart';
import 'package:adhd_journal_flutter/record_view_card_class.dart';
import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'splash_screendart.dart';
import 'package:intl/intl.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';


class RecordDisplayWidget extends StatefulWidget {
  const RecordDisplayWidget({Key? key}) : super(key: key);

  @override
  State<RecordDisplayWidget > createState() => RecordDisplayWidgetState();
  }

class RecordDisplayWidgetState extends State<RecordDisplayWidget>{
  late ValueListenableBuilder testMe;
  late Text titleHdr;
 RecordsNotifier recNotifier = RecordsNotifier(records);
  Future<List<Records>> _recordList = RecordsDB.records();
  var _selectedIndex = 0;
  String header = "";
late ValueListenableBuilder tryMe;

  static const TextStyle optionStyle =
  TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    try {
      loadPrefs();
      getList();
        ///Load the DB into the app

        setState(() {
loadList();
testMe =  ValueListenableBuilder(valueListenable: recNotifier.valueNotifier, builder:
    (BuildContext context,value,child){

  return ListView.builder(itemBuilder: (context, index) {
    return GestureDetector(
      child: Card(
          child: ListTile(    onTap: () {
            _editRecord(index);
          },
            title: RecordCardViewWidget(record: records[index],),
          )
      ),
      onHorizontalDragStart: (_) {
        //Add a dialog box method to allow for challenges to deleting entries
        setState(() {
          final deletedRec = records[index];
          RecordsDB.deleteRecord(deletedRec.id);
          records.remove(deletedRec);

        });
      },
    );
  },
    itemCount: records.length,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,
  );

},);

      }
);
      (recordWaitingPeriod() );


    } catch (e, s) {
      print(s);
    }
  }

  recordWaitingPeriod() async{
  var duration = const Duration(seconds: 1);

return Timer(duration,testME);
  }

void loadList() async{
  records = await _recordList;
    records.sort((a,b)=> a.compareTimesUpdated(b.timeUpdated));
    records = records.reversed.toList();
    RecordList.loadLists();
}

  void loadPrefs() async{
    prefs = await SharedPreferences.getInstance();
    greeting = prefs.getString('greeting') ?? '';
  }

  /// This loads the db list into the application for displaying.
  void getList() async {
    _recordList = RecordsDB.records();
  }
void testME(){
    setState((){
      testMe.createState();
    });
}

 

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true
  void _editRecord(int index) {
    setState(() {
      final Records loadRecord = records[index];
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ComposeRecordsWidget(
            record: loadRecord, id: 1,title: 'Edit Entry',)))
          .then((loadRecord) =>
          setState(() {
            //loadList();
           // RecordList.loadLists();
          }));
    });
  }




  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return  Column(key: UniqueKey(),
      children: <Widget>[
        const SizedBox(
          height: 20),Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 15.0, top: 15, bottom: 15.0),
          child:Row(children:[Expanded(child: Text(
            'Welcome back $greeting! What would you like to record today?',
            style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),),],
          ),
        ),
        Expanded(child:ValueListenableBuilder(valueListenable: recNotifier.valueNotifier, builder:
            (BuildContext context,value,child){

          return ListView.builder(itemBuilder: (context, index) {
            return GestureDetector(
              child: Card(
                  child: ListTile(    onTap: () {
                    _editRecord(index);
                  },
                    title: RecordCardViewWidget(record: records[index],),
                  )
              ),
              onHorizontalDragStart: (_) {
                //Add a dialog box method to allow for challenges to deleting entries
                setState(() {
                  final deletedRec = records[index];
                  RecordsDB.deleteRecord(deletedRec.id);
                  records.remove(deletedRec);
                  // loadList();
                });
              },
            );
          },
            itemCount: records.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
          );

        },)


        ),
      ],
    );
   
  }
}
class RecordsNotifier extends ValueNotifier<List<Records>>{
  RecordsNotifier(List<Records> recordList) : super(recordList);
  ValueNotifier valueNotifier = ValueNotifier(records.length);

  void updateListCount(int length){
//RecordList.loadLists();
    valueNotifier.notifyListeners();
  }




}