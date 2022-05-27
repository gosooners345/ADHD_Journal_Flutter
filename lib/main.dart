// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:async';
import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_list_class.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:adhd_journal_flutter/settings_tutorials/compose_tutorial.dart';
import 'package:adhd_journal_flutter/settings_tutorials/dashboard_help.dart';
import 'package:adhd_journal_flutter/settings_tutorials/sort_and_filter_help.dart';
import 'package:adhd_journal_flutter/settings_tutorials/tutorial_help_guide.dart';
import 'package:adhd_journal_flutter/splash_screendart.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'onboarding_widget_class.dart';
import 'record_display_widget.dart';
import 'package:flutter/material.dart';
import 'project_colors.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';

List<Records> recordHolder = [];
int id = 0;
void main() {
  runApp(MyApp());
}

late PackageInfo packInfo;
late RecordsBloc recordsBloc;

int listSize = 0;

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'ADHD Journal',
      theme: ThemeData(
          colorSchemeSeed: AppColors.mainAppColor,
          useMaterial3: true,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          colorSchemeSeed: AppColors.mainAppColor,
          useMaterial3: true,
          brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnBoardingWidget(),
        '/savePassword': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/success': (context) => ADHDJournalApp(),
        '/fail': (context) => LoginScreen(),
        '/composehelp': (context) => ComposeHelpWidget(),
        '/tutorials': (context) => TutorialHelpScreen(),
        '/dashboardhelp': (context) => DashboardHelp(),
        '/searchhelp': (context) => SortHelp(),
      },
    );
  }
}

class ADHDJournalApp extends StatefulWidget {
  const ADHDJournalApp({
    Key? key,
  }) : super(key: key);

  @override
  State<ADHDJournalApp> createState() => ADHDJournalAppHPState();
}

late ListView recordViews;

class ADHDJournalAppHPState extends State<ADHDJournalApp> {
  static Choice selectedChoice = sortOptions[0];
  String title = '';
  var _selectedIndex = 0;
  String header = "";
  var listCount = 0;
  @override
  void initState() {
    super.initState();
    title = 'Home';
    try {
      recordsBloc = RecordsBloc();
      buildNumber = packInfo.version;
    } on Exception catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.toString()),
          duration: const Duration(milliseconds: 1500),
          width: 280.0,
          // Width of the SnackBar.
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
      );
    }
  }

  List<Widget> screens() {
    return const [RecordDisplayWidget(), DashboardViewWidget()];
  }

  List<AppBar> appBars() {
    return [
      AppBar(
        title: Text("Home"),
        leading: IconButton(
            onPressed: () {
              recordsBloc.dispose();
              if (callingCard) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              }
            },
            icon: Icon(Icons.arrow_back)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Search Records'),
                  content: Padding(
                    padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Search here',
                          hintText: 'Enter your search topic here.'),
                      expands: false,
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          if (searchController.text.isNotEmpty) {
                            recordsBloc
                                .getSearchedRecords(searchController.text);
                          } else {
                            recordsBloc.getRecords();
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Search')),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return <PopupMenuItem>[
                (PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.restart_alt),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Reset')
                    ],
                  ),
                  onTap: () {
                    recordsBloc.getRecords();
                  },
                )),
                PopupMenuItem(
                  child: Text("Sort by"),
                  enabled: false,
                ),
                (PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.history),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Most Recent')
                    ],
                  ),
                  onTap: () {
                    recordsBloc.getSortedRecords("Most Recent");
                  },
                )),
                PopupMenuItem(
                    child: Row(
                      children: const [
                        Icon(Icons.sort_by_alpha),
                        SizedBox(
                          width: 10,
                        ),
                        Text('Alphabetical')
                      ],
                    ),
                    onTap: () {
                      recordsBloc.getSortedRecords("Alphabetical");
                    }),
                (PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.history),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Time Created')
                    ],
                  ),
                  onTap: () {
                    recordsBloc.getSortedRecords("Time Created");
                  },
                )),
                (PopupMenuItem(
                  child: Row(
                    children: const [
                      Icon(Icons.stars),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Rating')
                    ],
                  ),
                  onTap: () {
                    recordsBloc.getSortedRecords("Rating");
                  },
                )),
              ];
            },
            icon: Icon(Icons.filter_list),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>

                          /// Change password upon exit if the password has changed.
                          /// Tested and Passed: 05/09/2022
                          SettingsPage())).then((value) => {
                    if (userPassword != dbPassword)
                      {
                        verifyPasswordChanged(),
                      },
                  });
            },
          ),
        ],
      ),
      AppBar(
        title: Text("Stats"),
        leading: IconButton(
            onPressed: () {
              recordsBloc.dispose();
              if (callingCard) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()));
              }
            },
            icon: Icon(Icons.arrow_back)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>

                          /// Change password upon exit if the password has changed.
                          /// Tested and Passed: 05/09/2022
                          SettingsPage())).then((value) => {
                    setState(() {
                      greeting = prefs.getString('greeting')!;
                    }),
                    if (userPassword != dbPassword)
                      {
                        verifyPasswordChanged(),
                      },
                  });
            },
          ),
        ],
      )
    ];
  }

  /// This is for the bottom navigation bar, this isn't related to the records at all.
  void _onItemTapped(int index) {
    setState(() {
      if (recordsBloc.recordHolder.isNotEmpty) {
        _selectedIndex = index;
        if (_selectedIndex == 0) {
          title = 'Home';
        } else {
          title = 'Dashboard';
          RecordList.loadLists();
        }
      } else {
        _selectedIndex = 0;
      }
    });
  }

  ///Updates greeting and password  that isn't tied to DB Password

  /// Allows users to create entries for the db and journal. Once submitted, the screen will update on demand.
  /// Checked and passed : true
  void _createRecord() async {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ComposeRecordsWidget(
                  record: Records(
                      id: recordsBloc.maxID,
                      title: '',
                      content: '',
                      emotions: '',
                      sources: '',
                      symptoms: '',
                      tags: '',
                      rating: 0.0,
                      success: false,
                      timeCreated: DateTime.now(),
                      timeUpdated: DateTime.now()),
                  id: 0,
                  title: 'Compose New Entry'))).then((value) => {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Record saved'),
                duration: const Duration(milliseconds: 1500),
                width: 280.0,
                // Width of the SnackBar.
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                ),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ),
            executeRefresh(),
          });
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true

// This is where the Buttons associated with the bottom navigation bar will be located.
  final dashboardButtonItem =
      BottomNavigationBarItem(label: 'Dashboard', icon: Icon(Icons.dashboard));
  final homeButtonItem =
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home');

  quickTimer() async {
    return Timer(Duration(milliseconds: 1), executeRefresh);
  }

  void executeRefresh() async {
    RecordList.loadLists();
    if (kDebugMode) {
      print('Executed');
    }
  }

  BottomNavigationBar bottomBar() {
    List<BottomNavigationBarItem> navBar = [
      homeButtonItem,
      dashboardButtonItem
    ];
    return BottomNavigationBar(
      items: navBar,
      onTap: _onItemTapped,
      currentIndex: _selectedIndex,
    );
  }

  void verifyPasswordChanged() {
    try {
      int results = getPasswordChangeResults();
      if (results == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password changed successfully!'),
            duration: const Duration(milliseconds: 1500),
            width: 280.0,
            // Width of the SnackBar.
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(10.0), right: Radius.circular(10.0)),
            ),
          ),
        );
      } else {
        throw Exception("Password Change Failed");
      }
    } on Exception catch (ex) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                ex.toString(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text('Your password change failed.'),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Ok"))
              ],
            );
          });
    }
  }

  void sortOption(Choice option) {
    setState(() {
      selectedChoice = option;
      recordsBloc.getSortedRecords(option.title);
    });
  }

  int getPasswordChangeResults() {
    try {
      recordsBloc.changeDBPasswords();
      return 0;
    } on Exception {
      return 1;
    }
  }

  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBars()[_selectedIndex],
      body: Center(child: screens().elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Record'),
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            try {
              _createRecord();
            } on Exception catch (ex) {
              // ignore: avoid_print
              print(ex);
            }
          });
        },
      ),
      bottomNavigationBar: bottomBar(),
    );
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> sortOptions = <Choice>[
  Choice(title: 'Most Recent', icon: Icons.history),
  Choice(title: 'Alphabetical', icon: Icons.sort_by_alpha),
  Choice(title: 'Time Created', icon: Icons.history),
  Choice(title: 'Rating', icon: Icons.stars)
];
