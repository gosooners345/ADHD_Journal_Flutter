// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'dart:io';

import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_list_class.dart';
import 'package:adhd_journal_flutter/record_view_card_class.dart';
import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:adhd_journal_flutter/splash_screendart.dart';
import 'package:flutter/services.dart';
import 'onboarding_widget_class.dart';
import 'record_display_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'package:intl/intl.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';

List<Records> recordHolder = [];
int id =0;
StartStuff stuff = StartStuff();
void main() {
  stuff = StartStuff();
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

String startRoute ='';

class StartStuff{
 // static late SharedPreferences _prefs;
  void start() async{
  prefs = await SharedPreferences.getInstance();
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key, }) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      debugShowMaterialGrid: false,
      title: 'ADHD Journal',
      theme: ThemeData(
      colorSchemeSeed: Colors.brown, useMaterial3: true
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) =>  SplashScreen(),
        '/onboarding' : (context) => OnBoardingWidget(),
        '/savePassword' : (context) => LoginScreen(),
        '/login' : (context) => LoginScreen(),
        '/success': (context) => ADHDJournalApp(title: 'ADHD Journal',),
        '/fail': (context) =>  LoginScreen(),

      },
    );
  }
}

class ADHDJournalApp extends StatefulWidget {
  const ADHDJournalApp({Key? key, required this.title, }) : super(key: key);


  final String title;

  @override
  State<ADHDJournalApp> createState() => _ADHDJournalAppHPState();
}
late ListView recordViews;
class _ADHDJournalAppHPState extends State<ADHDJournalApp> {
  late FutureBuilder testMe;
  late Text titleHdr;
  var _selectedIndex = 0;
  String header = "";

  @override
  void initState() {
    super.initState();
    try {
      loadPrefs();
      setState(() {
        ///Load the DB into the app
      }
      );
    } catch (e, s) {
      print(s);
    }
  }


  List<Widget> screens(){
  return [
    RecordDisplayWidget(),DashboardViewWidget()
  ];
  }

void loadPrefs() async{
    prefs = await SharedPreferences.getInstance();
    greeting = prefs.getString('greeting') ?? '';
}

  /// This loads the db list into the application for displaying.



  /// This is for the bottom navigation bar, this isn't related to the records at all.
  void _onItemTapped(int index) {
    setState(() {
     if(recordHolder.isNotEmpty) {
       _selectedIndex = index;
       RecordList.loadLists();
     }
    });
  }



  /// Allows users to create entries for the db and journal. Once submitted, the screen will update on demand.
  /// Checked and passed : true
  void _createRecord() {
    setState(() {
      titleHdr = Text('Record Created');
      if(recordHolder.isEmpty) {
        id =1;
      } else {
        id = recordHolder[recordHolder.length - 1].id + 1;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ComposeRecordsWidget(
              record: Records(id: id, title: '', content: '',emotions: '',sources: '',symptoms: '',tags: '',rating: 0.0,success: false,timeCreated:
DateTime.now() ,timeUpdated: DateTime.now())
              , id: 0,title: 'Compose New Entry')))
          .then((value) =>
          setState(() {}));
    });
  }

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true


// This is where the Buttons associated with the bottom navigation bar will be located.
  var dashboardButtonItem = BottomNavigationBarItem(
      label: 'Dashboard',
  icon: Icon(Icons.dashboard)
      );
  var homeButtonItem = BottomNavigationBarItem(icon: Icon(Icons.home),
  label: 'Home');

  BottomNavigationBar bottomBar(){
    List<BottomNavigationBarItem> navBar = [homeButtonItem,dashboardButtonItem];
    return BottomNavigationBar(items: navBar,onTap: _onItemTapped,currentIndex: _selectedIndex,);
  }


  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), leading:  IconButton(onPressed: (){
        Navigator.pop(context);
        },
          icon: Icon(Icons.arrow_back)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings),onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) =>
            // This will test whether we need to even replace the DB File on the iOS device or not. We will test the db later when we change keys.
            // when this happens we will close the app and open it with the new key.
            //Test Results in: iOS works without the close and reopening.
            SettingsPage())).then((value) =>
            {
              if(userPassword != dbPassword){
                if(Platform.isAndroid){
                  recdatabase.close(),
                },

                recordsDataBase.changePasswords(),
                if(Platform.isAndroid){
                  recordsDataBase.getDBLoaded(true),
                },
              },
            });
          },
          ),
        ],
      ),
      body: Center(child: screens().elementAt(_selectedIndex)),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Record'), icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _createRecord();
          }
          );
        },
      ),
      bottomNavigationBar: bottomBar(),

    );
  }

}
