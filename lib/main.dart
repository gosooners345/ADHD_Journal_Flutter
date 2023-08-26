// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:async';

//import 'package:adhd_journal_flutter/adhd_ml_engine_package/ml_kit_class.dart';
import 'package:adhd_journal_flutter/project_resources/project_utils.dart';
import 'package:adhd_journal_flutter/settings_tutorials/backup_and_sync_help.dart';
import 'package:adhd_journal_flutter/ui/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_data_package/record_list_class.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:adhd_journal_flutter/settings_link_page/helpful_links.dart';
import 'package:adhd_journal_flutter/settings_tutorials/compose_tutorial.dart';
import 'package:adhd_journal_flutter/settings_tutorials/dashboard_help.dart';
import 'package:adhd_journal_flutter/settings_tutorials/sort_and_filter_help.dart';
import 'package:adhd_journal_flutter/settings_tutorials/tutorial_help_guide.dart';
import 'package:adhd_journal_flutter/app_start_package/splash_screendart.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'app_start_package/onboarding_widget_class.dart';
import 'notifications_packages/notification_controller.dart';
import 'ui/record_display_widget.dart';
import 'package:flutter/material.dart';
import 'project_resources/project_colors.dart';
import 'record_data_package/records_data_class_db.dart';
import 'app_start_package/login_screen_file.dart';
import 'records_compose_components/new_compose_records_screen.dart';

List<Records> recordHolder = [];
int id = 0;

Future<void> main() async {
  await NotificationController.initializeLocalNotifications();

  runApp(ChangeNotifierProvider<ThemeSwap>(
    create: (_) => ThemeSwap(),
    child: MyApp(),
  ));
}

late RecordsBloc recordsBloc;

int listSize = 0;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    NotificationController.startListeningNotificationEvents();
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final swapper = Provider.of<ThemeSwap>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'ADHD Journal',
      theme: ThemeData(
          colorSchemeSeed: Color(swapper.isColorSeed),
          useMaterial3: true,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          colorSchemeSeed: Color(swapper.isColorSeed),
          useMaterial3: true,
          brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      themeAnimationDuration: Duration(seconds: 2),
      themeAnimationCurve: Curves.fastEaseInToSlowEaseOut,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/notification': (context) => SplashScreen(),
        '/onboarding': (context) => OnBoardingWidget(),
        '/savePassword': (context) => LoginScreen(
              swapper: swapper,
            ),
        '/login': (context) => LoginScreen(
              swapper: swapper,
            ),
        '/success': (context) => ADHDJournalApp(),
        '/fail': (context) => LoginScreen(
              swapper: swapper,
            ),
        '/composehelp': (context) => ComposeHelpWidget(),
        '/tutorials': (context) => TutorialHelpScreen(),
        '/dashboardhelp': (context) => DashboardHelp(),
        '/searchhelp': (context) => SortHelp(),
        '/resources': (context) => HelpfulLinksWidget(),
        '/backuphelp': (context) => BackupAndSyncdHelp(),
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
      buildInfo = packInfo.version;
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

  static const List<Widget> screens =
     [RecordDisplayWidget(), DashboardViewWidget()];


  void encryptData() async {
    await Future.sync(() {
      preferenceBackupAndEncrypt.encryptData(
          "$userPassword,$dbPassword,$passwordHint,$passwordEnabled,$greeting,$colorSeed",
          googleDrive);
    });
  }

  List<AppBar> appBars() {
    return [
      AppBar(
        title: Text("Home"),
        leading: IconButton(
            onPressed: () {
              isThisReturning = true;
              recordsBloc.dispose();
              Navigator.pop(context);
            },
            icon: backArrowIcon),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Search Entries'),
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
                PopupMenuItem(
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
                ),
                PopupMenuItem(
                  enabled: false,
                  child: Text("Sort by"),
                ),
                PopupMenuItem(
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
                ),
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
              Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SettingsPage()))
                  .then((value) => {
                        if (userPassword != dbPassword)
                          {
                            recordsBloc.changeDBPasswords(userPassword),
                            recordsBloc = RecordsBloc()
                          },
                        userActiveBackup = prefs.getBool("testBackup") ?? false,
                        if (userActiveBackup) {encryptData()},
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
              Navigator.of(context).pop();
            },
            icon: backArrowIcon),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,

                  MaterialPageRoute(
                      builder: (_) =>
                      
                    SettingsPage())).then((value) => {
                    setState(() {
                      greeting = prefs.getString('greeting')!;
                    }),
                    if (userPassword != dbPassword)
                      {
                        recordsBloc.changeDBPasswords(userPassword),
                        recordsBloc = RecordsBloc(),
                        recordsBloc.getRecords()
                      },
                    userActiveBackup = prefs.getBool("testBackup") ?? false,
                    if (userActiveBackup) {
                      encryptData()
                    },
                  });
            },
          ),
        ],
      )
    ];
  }



  /// Allows users to create entries for the db and journal. Once submitted, the screen will update on demand.
  /// Checked and passed : true
  void _createRecord() async {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => NewComposeRecordsWidget(
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
            recordsBloc.writeCheckpoint()
          });
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true
  ///
// This is where the Buttons associated with the bottom navigation bar will be located.

  void verifyPasswordChanged() {
    try {
      int results = getPasswordChangeResults();
      if (results == 0) {
        showAlert(context, "Password Change Successful!");
      } else {
        throw Exception("Password Change Failed");
      }
    } on Exception {
      showAlert(context, "Password Change failed");
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
      recordsBloc.changeDBPasswords(userPassword);
      return 0;
    } on Exception {
      return 1;
    }
  }

  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
      builder: (context, swapper, child) {
        return Scaffold(
          appBar: appBars()[_selectedIndex],
          body:
          screens.elementAt(_selectedIndex),
          //Center(child: screens.elementAt(_selectedIndex)),
          floatingActionButton: FloatingActionButton.extended(
            label: Text('Compose'),
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                try {
                  _createRecord();
                } on Exception catch (ex) {

                  if (kDebugMode) {
                    print(ex);
                  }
                }
              });
            },
          ),
          bottomNavigationBar:
          NavigationBar(selectedIndex: _selectedIndex,
            onDestinationSelected: (int index){
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
            },
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), label: "Home",selectedIcon: Icon(Icons.home),tooltip: "The diary",),
              NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: "Dashboard",selectedIcon: Icon(Icons.dashboard),tooltip: "The dashboard",)
            ],

          )


          //bottomBar(),
        );
      },
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
