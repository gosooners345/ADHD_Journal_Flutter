// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_view_card_class.dart';
import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:flutter/services.dart';
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

List<Records> records = [];
//late SharedPreferences prefs;
int id =0;
StartStuff stuff = StartStuff();
void main() {
  stuff = StartStuff();
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}



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
      title: 'ADHD Journal',
      theme: ThemeData(

        primarySwatch: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/' : (context) =>  LoginScreen(),
        '/success': (context) => MyHomePage(title: 'ADHD Journal',),
        '/fail': (context) =>  LoginScreen(),

      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title, }) : super(key: key);


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
late ListView recordViews;
class _MyHomePageState extends State<MyHomePage> {
  late FutureBuilder testMe;
  late Text titleHdr;
  Future<List<Records>> _recordList = RecordsDB.records();
  var _selectedIndex = 0;
  String header = "";

  @override
  void initState() {
    super.initState();
    try {
      loadPrefs();
      setState(() {
        ///Load the DB into the app
        _recordList = RecordsDB.records();
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
  void getList() async {
    _recordList = RecordsDB.records();
  }


  /// This is for the bottom navigation bar, this isn't related to the records at all.
  void _onItemTapped(int index) {
    setState(() {
     
      _selectedIndex = index;
    });
  }

  /// Allows users to create entries for the db and journal. Once submitted, the screen will update on demand.
  /// Checked and passed : true
  void _createRecord() {
    setState(() {
      titleHdr = Text('Record Created');
      if(records.isEmpty) {
        id =1;
      } else {
        id = records[records.length - 1].id + 1;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ComposeRecordsWidget(
              record: Records(id: id, title: '', content: '',emotions: '',sources: '',symptoms: '',tags: '',rating: 0.0,success: 'success/fail',timeCreated:
DateFormat('MM/dd/yyyy hh:mm:ss:aa').format(DateTime.now().toLocal()) ,timeUpdated: DateFormat('MM/dd/yyyy hh:mm:ss:aa').format(DateTime.now().toLocal()))
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
        title: Text(widget.title), actions: <Widget>[
          IconButton(icon: Icon(Icons.settings),onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (_)=>
            SettingsPage())).then((value) =>
             {
               RecordsDB.db(),
               _recordList= RecordsDB.records()
             });},),],),
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
