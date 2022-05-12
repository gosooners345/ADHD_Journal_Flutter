// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:async';
import 'dart:io';

import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_list_class.dart';
import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:adhd_journal_flutter/splash_screendart.dart';
import 'onboarding_widget_class.dart';
import 'record_display_widget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'project_colors.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';

List<Records> recordHolder = [];
int id = 0;
void main() {


 runApp(MyApp());


}


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
      theme: ThemeData(colorSchemeSeed: AppColors.mainAppColor, useMaterial3: true),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnBoardingWidget(),
        '/savePassword': (context) => LoginScreen(),
        '/login': (context) => LoginScreen(),
        '/success': (context) => ADHDJournalApp(
              title: 'ADHD Journal',
            ),
        '/fail': (context) => LoginScreen(),
      },
    );
  }
}

class ADHDJournalApp extends StatefulWidget {
  const ADHDJournalApp({
    Key? key,
    required this.title,

  }) : super(key: key);

  final String title;

  @override
  State<ADHDJournalApp> createState() => _ADHDJournalAppHPState();
}

late ListView recordViews;

class _ADHDJournalAppHPState extends State<ADHDJournalApp> {
 Choice _selectedChoice = sortOptions[0];
  late Text titleHdr;
  var _selectedIndex = 0;
  String header = "";

  @override
  void initState() {
    super.initState();
    try {
        loadDB();

    } catch (e, s) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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


  void loadDB() async {
    try {
      recdatabase = await RecordsDB.initializeDB();
      if (recdatabase.isOpen) {
        print("DB open");
      }
      recordHolder = await RecordsDB.getRecords();
      setState((){
     recordHolder.sort((a,b)=> a.compareTo(b));
      });

      RecordList.loadLists();
    } on Exception catch (ex) {
      print(ex);
    }
  }

  List<Widget> screens() {
    return const [RecordDisplayWidget(),DashboardViewWidget()];
  }


  /// This is for the bottom navigation bar, this isn't related to the records at all.
  void _onItemTapped(int index) {
    setState(() {
      if (recordHolder.isNotEmpty) {
        _selectedIndex = index;
        RecordList.loadLists();
      }
    });
  }

  /// Allows users to create entries for the db and journal. Once submitted, the screen will update on demand.
  /// Checked and passed : true
  void _createRecord() {
    setState(() {
      if (recordHolder.isEmpty) {
        id = 1;
      } else {
        id = recordHolder.length+1;
      }
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ComposeRecordsWidget(
                      record: Records(
                          id: id,
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
                      title: 'Compose New Entry')))
          .then((value) => {
quickTimer()
//      setState((){recordListHolderWidget.createState();})


      });
    });
  }

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true

// This is where the Buttons associated with the bottom navigation bar will be located.
  final dashboardButtonItem =
  BottomNavigationBarItem(label: 'Dashboard', icon: Icon(Icons.dashboard));
  final homeButtonItem =
  BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home');


  void sortCreated() async{

  }
  sortTimer(String callbackName) async{
    Function callback;
    switch(callbackName){
      case 'Recent': callback = executeRefresh;break;
      case 'Created' : break;

    }

    var duration = const Duration(milliseconds: 100);
  //  return Timer(duration,callback);

  }


  quickTimer() async{
    return Timer(Duration(milliseconds:1),executeRefresh);
  }
  void executeRefresh() async{
    setState((){
      recordHolder.sort((a,b)=> a.compareTo(b));

    });
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:  Image.asset('images/app_icon_demo.png'),
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
      }
      else {
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

  void sortOption(Choice option){

    setState((){
      _selectedChoice = option;
    });

    switch (option.title){
      case 'Alphabetical' : {
        setState((){
          recordHolder.sort((a,b)=>a.compareTitles(b.title));

        });
        break;
      }
      case  'Rating':{
        setState((){
          recordHolder.sort((a,b) => a.compareRatings(b.rating));
        });
        break;
      }
      case 'Time Created': {
        setState((){
          recordHolder.sort((a,b) => a.compareTimesCreated(b.timeCreated));
        });
        break;
      }
      case 'Most Recent': {setState((){
        recordHolder.sort((a,b)=>a.compareTo(b)); });
      break;}
    }
  }


  int getPasswordChangeResults() {
    try {
      RecordsDB.changePasswords();
      return 0;
    }
    on Exception catch (ex) {
      return 1;
    }
  }

  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
            onPressed: () {
              if (recdatabase.isOpen) {
                recdatabase.close();
              }
              if (callingCard) {
                Navigator.pop(context);
              }
              else {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
              }
            },
            icon: Icon(Icons.arrow_back)),
        actions: <Widget>[
          PopupMenuButton<Choice>(itemBuilder: (BuildContext context){
            return sortOptions.map((Choice choice){
              return PopupMenuItem<Choice>(child: Text(choice.title),
              value: choice,);
            }).toList();
          },),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>

                      /// Change password upon exit if the password has changed.
                      /// Tested and Passed: 05/09/2022
                      SettingsPage())).then((value) =>{
                if (userPassword != dbPassword){
                    verifyPasswordChanged(),
                  },
              });
            },
          ),
        ],
      ),
      body: Center(child: screens().elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Record'),
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _createRecord();
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
  Choice(title: 'Most Recent',icon: Icons.history),
   Choice(title: 'Alphabetical', icon: Icons.sort_by_alpha),
   Choice(title: 'Time Created',icon:  Icons.history),
   Choice(title: 'Rating',icon: Icons.stars)
];