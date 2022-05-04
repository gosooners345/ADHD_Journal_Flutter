
import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_view_card_class.dart';
import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:adhd_journal_flutter/settings.dart';
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
  late FutureBuilder testMe;
  late Text titleHdr;
  Future<List<Records>> _recordList = RecordsDB.records();
  var _selectedIndex = 0;
  String header = "";

  static const TextStyle optionStyle =
  TextStyle(fontSize: 15, fontWeight: FontWeight.bold);

  @override
  void initState() {
    super.initState();
    try {
      loadPrefs();
      setState(() {
        ///Load the DB into the app
        _recordList = RecordsDB.records();
        /// This controls the ListView widget responsible for displaying user data on screen
       /* testMe = FutureBuilder<List<Records>>(
            future: _recordList,
            builder: (BuildContext context,
                AsyncSnapshot<List<Records>> snapshot,) {
              /// If all goes well, data is displayed, if not, then the errors show up.
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error has occurred ${snapshot.error}'),
                  );
                }
                else if (snapshot.hasData) {
                  records = snapshot.data as List<Records>;
                  return ListView.builder(itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Card(
                          child:
                          ListTile(
                            onTap: () {
                              _editRecord(index);
                            },
                            title: RecordCardViewWidget(record: records[index],),
                          )
                      ),
                      onHorizontalDragEnd: (_) {
                        var deleted = false;
                        //Add a dialog box method to allow for challenges to deleting entries
                        setState(() {
                          showDialog(context: context, barrierDismissible: false,
                              builder: (BuildContext context){
                            return AlertDialog(
                              title: const Text('Delete Record?'),
                              content: const Text('Are you sure you want to delete this record?'
                                  'You can\'t undo this once you hit yes.',),
                              actions: [
                                TextButton(onPressed: (){
                                  final deletedRec = records[index];
                                  RecordsDB.deleteRecord(deletedRec.id);

                                  deleted = true;
                                  Navigator.pop(context);
                               }, child: const Text('Yes')),
                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('No'))
                              ],
                            );
                              });

                        });
                        if(deleted){
                          records.removeAt(index);
                        }
                      },
                    );
                  },
                    itemCount: records.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        );*/
      }
      );
    } catch (e, s) {
      print(s);
    }
  }

  void loadPrefs() async{
    prefs = await SharedPreferences.getInstance();
    greeting = prefs.getString('greeting') ?? '';
  }

  /// This loads the db list into the application for displaying.
  void getList() async {
    _recordList = RecordsDB.records();
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
          setState(() {}));
    });
  }




  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return  Column(key: UniqueKey(),
      children: <Widget>[
        SizedBox(
          height: 20),Padding(
          padding: const EdgeInsets.only(
              left: 15.0, right: 15.0, top: 15, bottom: 15.0),
          child:Row(children:[Expanded(child: Text(
            'Welcome back $greeting! What would you like to record today?',
            style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),),],
          ),
        ),
        Expanded(child: FutureBuilder<List<Records>>(
            future: _recordList,
            builder: (BuildContext context,
                AsyncSnapshot<List<Records>> snapshot,) {
              /// If all goes well, data is displayed, if not, then the errors show up.
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error has occurred ${snapshot.error}'),
                  );
                }
                else if (snapshot.hasData) {
                  records = snapshot.data as List<Records>;
                  return ListView.builder(itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Card(
                          child:
                          ListTile(
                            onTap: () {
                              _editRecord(index);
                            },
                            title: RecordCardViewWidget(record: records[index],),
                          )
                      ),
                      onHorizontalDragEnd: (_) {
                        var deleted = false;
                        //Add a dialog box method to allow for challenges to deleting entries
                        setState(() {
                            final deletedRec = records[index];
                            RecordsDB.deleteRecord(deletedRec.id);
                            records.removeAt(index);
                        });

                      },
                    );
                  },
                    itemCount: records.length,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
        )),
      ],
    );
   
  }
}
