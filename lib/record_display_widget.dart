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
  State<RecordDisplayWidget> createState() => RecordDisplayWidgetState();
}


class RecordDisplayWidgetState extends State<RecordDisplayWidget> {

  late Text titleHdr;
  RecordsNotifier recNotifier = RecordsNotifier(recordHolder);
  String header = "";

  @override
  void initState() {
    super.initState();
    try {
      setState((){
     recordHolder.sort((a,b)=>a.compareTo(b));
      });
      greeting = prefs.getString('greeting') ?? '';
     startTimer();
  quickTimer();
print('everything is sorted now');
    } catch (e, s) {
      print(s);
    }
  }

  startTimer() async{
    var duration = const Duration(seconds: 3);

    return Timer(duration,executeClick);
  }
  void executeClick() async {
    setState(() {
      recordHolder.sort((a, b) => a.compareTo(b));
    });
  }
quickTimer() async {
  var duration = const Duration(milliseconds: 1);
   return Timer(duration,executeClick);
}


void sortCreated() async{

}

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true
  void _editRecord(int index) {
    setState(() {
      final Records loadRecord = recordHolder[index];
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ComposeRecordsWidget(
                    record: loadRecord,
                    id: 1,
                    title: 'Edit Entry',
                  ))).then((value) => {
      quickTimer()
                  }
      );});
    }

  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 15.0, top: 15, bottom: 15.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Welcome back $greeting! What would you like to record today?',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),),],),),
        Expanded(
            child:ValueListenableBuilder(valueListenable: recNotifier.valueNotifier, builder:
    (BuildContext context,value,child)
    {return  ListView.builder(itemBuilder: (context, index) {
    return GestureDetector(
    child: Card(
    child: ListTile( onTap: () {
    _editRecord(index);
    },
    title: RecordCardViewWidget(record: recordHolder[index],),
    )
    ),
    onHorizontalDragStart: (_) {
    //Add a dialog box method to allow for challenges to deleting entries
    setState(() {
    final deletedRec = recordHolder[index];
    RecordsDB.deleteRecord(deletedRec.id);
    recordHolder.remove(deletedRec);
    recordHolder.sort((a,b)=>a.compareTo(b));
    });
    },
    );
    },
    itemCount: recordHolder.length,
    scrollDirection: Axis.vertical,
    shrinkWrap: true,

    );
    },
    ),

            )


            //recordListHolderWidget),
      ],
    );
  }
}

class RecordsNotifier extends ValueNotifier<List<Records>> {
  RecordsNotifier(List<Records> recordList) : super(recordList);
  ValueNotifier valueNotifier = ValueNotifier(recordHolder);

  void updateListCount(int length) {
    valueNotifier.notifyListeners();
  }
}
