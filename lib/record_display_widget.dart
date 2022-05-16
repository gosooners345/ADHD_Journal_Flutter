import 'dart:async';

import 'package:adhd_journal_flutter/record_list_class.dart';
import 'package:adhd_journal_flutter/record_view_card_class.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:flutter/foundation.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'project_colors.dart';
import 'splash_screendart.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';

class RecordDisplayWidget extends StatefulWidget {
  const RecordDisplayWidget({Key? key}) : super(key: key);

  @override
  State<RecordDisplayWidget> createState() => RecordDisplayWidgetState();
}

late TextEditingController searchController;

class RecordDisplayWidgetState extends State<RecordDisplayWidget> {
    @override
  void initState() {
    super.initState();
    try {
      searchController = TextEditingController();
      recordsBloc = RecordsBloc();
    startTimer();
      greeting = prefs.getString('greeting') ?? '';
      if (kDebugMode) {
        print('everything is sorted now');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print(s);
      }
    }
  }


  startTimer() async{
    var duration = const Duration(seconds: 2);

    return Timer(duration,executeClick);
  }
  void executeClick() async {
    RecordList.loadLists();

  }


/// Stream widget testing here
  Widget getRecordsDisplay(){

    return StreamBuilder(stream: recordsBloc.recordStuffs,
      builder: (BuildContext context, AsyncSnapshot<List<Records>> snapshot){
      return getRecordCards(snapshot);
    },);
  }
  Widget getRecordCards(AsyncSnapshot<List<Records>> snapshot){
    if(snapshot.hasData){

    return snapshot.data!.isNotEmpty ?
    ListView.builder(itemBuilder: (context, index) {
      Records record = snapshot.data![index];


      Widget dismissableCard =
      Dismissible(
        background: Card(shape:  RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),elevation: 2.0,
          child:const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Deleting",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          color: AppColors.mainAppColor,
        ),
        key:  ObjectKey(record),
        child:Card(
          shape: RoundedRectangleBorder(side: BorderSide(color: AppColors.mainAppColor,width: 1.0),borderRadius: BorderRadius.circular(10)),
          child: ListTile( onTap: () {
            _editRecord(record);
          },
            title: RecordCardViewWidget(record: record,),
          )
      ),onDismissed: (direction){

        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete Record?'),
              content: const Text('Are you sure you want to delete this record?'
                  ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      recordsBloc.deleteRecordByID(record.id);
                      print('Deleted Record');
                    },
                    child: const Text('Yes')),
        TextButton( child:Text('No'),
          onPressed:(){
          recordsBloc.getRecords();
          Navigator.pop(context);
          }
                )
              ],
            ));


      },
        direction: DismissDirection.horizontal,

      );
    return dismissableCard;
      },
      itemCount: snapshot.data?.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,

    ): const Center( child: Text('Add a new record by hitting the Record button below!'),);
  }
    else if(snapshot.hasError){
      if (kDebugMode) {
        print(snapshot.error);
      }
      return Text(snapshot.stackTrace.toString());
    }
    else{
      if (kDebugMode) {
        print(snapshot.connectionState);
      }
      return Center(
        child: Center(
          child: Column(children: const <Widget>[
            CircularProgressIndicator(),
            Text('Loading your records'),
          ],),
        ),
      );
    }
  }

@override
  dispose(){
    super.dispose();
    recordsBloc.dispose();
}

/// Sorts the list based on what the user prefers to see.


  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true
  void _editRecord(Records record) {
    setState(() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ComposeRecordsWidget(
                    record: record,
                    id: 1,
                    title: 'Edit Entry',
                  ))      );});
    }

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
                  style: const TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),),],),),
        Expanded(
            child:getRecordsDisplay()
                            )
      ],
    );
  }
}
