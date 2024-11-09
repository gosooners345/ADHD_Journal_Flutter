import 'dart:async';

import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:adhd_journal_flutter/record_data_package/record_list_class.dart';
import 'package:adhd_journal_flutter/ui_components/record_view_card_class.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import 'package:flutter/material.dart';
import '../project_resources/project_colors.dart';
import '../app_start_package/splash_screendart.dart';
import '../project_resources/project_utils.dart';
import '../record_data_package/records_data_class_db.dart';
import '../app_start_package/login_screen_file.dart';
import '../records_compose_components/new_compose_records_screen.dart';
import '../ui_components/loading_card_widget.dart';

class RecordDisplayWidget extends StatefulWidget {
  const RecordDisplayWidget({Key? key}) : super(key: key);

  @override
  State<RecordDisplayWidget> createState() => RecordDisplayWidgetState();
}

TextEditingController passwordHintController = TextEditingController();
late TextEditingController searchController;

class RecordDisplayWidgetState extends State<RecordDisplayWidget> with SingleTickerProviderStateMixin{


  @override
  void initState() {
    super.initState();

    try {
      searchController = TextEditingController();
      recordsBloc = RecordsBloc();
      startTimer();
      greeting = prefs.getString('greeting') ?? '';
      checkHint();
      if (kDebugMode) {
        print('everything is sorted now');
      }
    } catch (e, s) {
      if (kDebugMode) {
        print(s);
      }
    }
  }
//Animations

// For updating the list when its opening. this
  startTimer() async {
    var duration = const Duration(seconds: 1);

    return Timer(duration, executeClick);
  }

  void checkHint() async {
    if (passwordHint == '' || passwordHint == ' ') {
      showAlertWithDelegate(
          context, "Password Hint Needed", "ADD Hint", enterSettings);
    }
  }

  void executeClick() async {
    RecordList.loadLists();
  }



  @override
  dispose() {
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
              builder: (_) => NewComposeRecordsWidget(
                    record: record,
                    id: 1,
                    title: 'Edit Entry',
                  ))).then((value) {
        showAlert(context, 'Record Saved');
        recordsBloc.writeCheckpoint();
        showAlert(context, "Changes to DB Saved");
      });
    });
  }

  void enterSettings(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              "Password Hint Needed",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: ListTile(
              title: const Text(password_hint_needed),
              subtitle: ListTile(
                title: TextField(
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password Hint',
                      hintText: 'Enter a password hint here.'),
                  onChanged: (text) {
                    passwordHint = text;
                  },
                ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    saveSettings(passwordHint, 'passwordHint');
                    Navigator.pop(context);
                    showAlert(context, "Password hint saved.");
                  },
                  child: const Text("Ok"))
            ],
          );
        });
  }

  Widget _buildListItem(bool isLoading) {
    return ShimmerLoading(
      isLoading: isLoading,
      child: CardListItem(
        isLoading: isLoading,
      ),
    );
  }

  void saveSettings(String value, String key) async {
    encryptedSharedPrefs.setString(key, value);
    await encryptedSharedPrefs.setString(key, value);
  }
// Go by date
  // Custom ScrollView, SliverList, Delegate, Child List Delegate

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return// SafeArea(
        //  minimum: const EdgeInsets.all(5.0),
      //    child:
      CustomScrollView(slivers:[
            SliverPadding(padding: const EdgeInsets.all(15),sliver:
            SliverList(delegate: SliverChildListDelegate([ const SizedBox(height: 20),
               Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Welcome back $greeting! What would you like to record today?',
                        style: const TextStyle(fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ])),),
SliverSafeArea(top: true,right: true,left: true,bottom: true,
  minimum: const EdgeInsets.symmetric(horizontal: 15),sliver:
SliverList(delegate:
SliverChildListDelegate([
  Divider(height: 5,thickness: 1.0,color: Color(swapper.isColorSeed),),
]),),),

      StreamBuilder(
      stream: recordsBloc.recordStuffs,
      builder: (BuildContext context, AsyncSnapshot<List<Records>> snapshot){
        if (snapshot.hasData) {
          return snapshot.data!.isNotEmpty
              ? SliverSafeArea(top: true,right: true,left: true,bottom: true,
              minimum: const EdgeInsets.symmetric(horizontal: 5),sliver:
          SliverList(delegate: SliverChildBuilderDelegate(
                  (context, index) {
                Records record = snapshot.data![index];
                Widget dismissableCard = Dismissible(
                  background: Card(
                    shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Color(swapper.isColorSeed), width: 1.0),
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 2.0,
                    color: Color(swapper.isColorSeed),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                Text(
                                  "Deleting",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ])),
                    ),
                  ),
                  key: ObjectKey(record),
                  confirmDismiss: (value) async {
                    return await showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Delete Entry?'),
                          content: const Text(
                              'Are you sure you want to delete this entry?'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes')),
                            TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                })
                          ],
                        ));
                  },
                  onDismissed: (direction) {
                    recordsBloc.deleteRecordByID(record.id);

                    recordsBloc.writeCheckpoint();
                    showAlert(context, "Entry Deleted");
                  },
                  direction: DismissDirection.horizontal,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Color(swapper.isColorSeed), width: 1.0),
                          borderRadius: BorderRadius.circular(18)),
                      child: ListTile(
                        onTap: () {
                          _editRecord(record);
                        },
                        title: RecordCardViewWidget(
                          record: record,
                        ),
                        contentPadding: const EdgeInsets.all(8),
                      )),
                );
                return dismissableCard;
              },
          childCount: snapshot.data?.length,

          ))):

                SliverList(delegate: SliverChildListDelegate([
               const Center(
            child: Text(
                'Add a new record by hitting the create button below!'),
          )]));

        } else if (snapshot.hasError) {
          if (kDebugMode) {
            print(snapshot.error);
          }
          return   SliverList(delegate: SliverChildListDelegate([ Text(snapshot.stackTrace.toString())]));
        } else { //if loading.
          if (kDebugMode) {
            print(snapshot.connectionState);
          }
          return
            SliverList(delegate: SliverChildListDelegate([
             Center(
            child: Center(
              child: Column(children: [_buildListItem(true)],
              ),
            ),
          )]));
        }
      },
      )]);



    });
  }
}
