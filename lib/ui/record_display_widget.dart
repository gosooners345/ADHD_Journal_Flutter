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
import '../record_data_package/records_data_class_db.dart';
import '../app_start_package/login_screen_file.dart';
import '../records_compose_components/new_compose_records_screen.dart';

class RecordDisplayWidget extends StatefulWidget {
  const RecordDisplayWidget({Key? key}) : super(key: key);

  @override
  State<RecordDisplayWidget> createState() => RecordDisplayWidgetState();
}

TextEditingController passwordHintController = TextEditingController();
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

// For updating the list when its opening. this
  startTimer() async {
    var duration = const Duration(seconds: 1);

    return Timer(duration, executeClick);
  }

  void checkHint() async {
    if (passwordHint == '' || passwordHint == ' ') {
      _showAlertWithDelegate(
          context, "Password Hint Needed", "ADD Hint", enterSettings);
    }
  }

  void executeClick() async {
    RecordList.loadLists();
  }

  /// Stream widget testing here
  Widget getRecordsDisplay() {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return StreamBuilder(
        stream: recordsBloc.recordStuffs,
        builder: (BuildContext context, AsyncSnapshot<List<Records>> snapshot) {
          return getRecordCards(snapshot);
        },
      );
    });
  }

  Widget getRecordCards(AsyncSnapshot<List<Records>> snapshot) {
    if (snapshot.hasData) {
      return Consumer<ThemeSwap>(builder: (context, swapper, child) {
        return snapshot.data!.isNotEmpty
            ? ListView.builder(
                itemBuilder: (context, index) {
                  Records record = snapshot.data![index];

                  Widget dismissableCard = Dismissible(
                    background: Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Color(swapper.isColorSeed), width: 1.0),
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 2.0,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Deleting",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      color: Color(swapper.isColorSeed),
                    ),
                    key: ObjectKey(record),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Color(swapper.isColorSeed), width: 1.0),
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          onTap: () {
                            _editRecord(record);
                          },
                          title: RecordCardViewWidget(
                            record: record,
                          ),
                          contentPadding: EdgeInsets.all(12),
                        )),
                    onDismissed: (direction) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                                title: const Text('Delete Entry?'),
                                content: const Text(
                                    'Are you sure you want to delete this entry?'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        recordsBloc.deleteRecordByID(record.id);
                                        _showAlert(context, "Entry Deleted");
                                        recordsBloc.writeCheckpoint();
                                      },
                                      child: const Text('Yes')),
                                  TextButton(
                                      child: Text('No'),
                                      onPressed: () {
                                        recordsBloc.getRecords();
                                        Navigator.pop(context);
                                      })
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
              )
            : const Center(
                child: Text(
                    'Add a new record by hitting the create button below!'),
              );
      });
    } else if (snapshot.hasError) {
      if (kDebugMode) {
        print(snapshot.error);
      }
      return Text(snapshot.stackTrace.toString());
    } else {
      if (kDebugMode) {
        print(snapshot.connectionState);
      }
      return Center(
        child: Center(
          child: Column(
            children: const <Widget>[
              CircularProgressIndicator(),
              Text('Loading your journal entries.'),
            ],
          ),
        ),
      );
    }
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
        _showAlert(context, 'Record Saved');
        recordsBloc.writeCheckpoint();
        _showAlert(context, "Changes to DB Saved");
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
                    _showAlert(context, "Password hint saved.");
                  },
                  child: const Text("Ok"))
            ],
          );
        });
  }

  void _showAlert(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
      ),
    );
  }

  void _showAlertWithDelegate(
      BuildContext context, String title, String message, Function delegate) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(title),
        action: SnackBarAction(
          label: message,
          onPressed: () {
            delegate(context);
          },
        ),
      ),
    );
  }

  void saveSettings(String value, String key) async {
    encryptedSharedPrefs.setString(key, value);
    await encryptedSharedPrefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
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
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: getRecordsDisplay())
        ],
      );
    });
  }
}
