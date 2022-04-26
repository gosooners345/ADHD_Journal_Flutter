// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:adhd_journal_flutter/dashboard_stats_display_widget.dart';
import 'package:adhd_journal_flutter/record_view_card_class.dart';
import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:adhd_journal_flutter/settings.dart';
import 'package:flutter/services.dart';
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
       '/dashboard': (context) => DashboardViewWidget(),
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
        testMe = FutureBuilder<List<Records>>(
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
              return Center(
                child: CircularProgressIndicator(),
              );
            }
        );
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


  /// This is for the bottom navigation bar, this isn't related to the records at all.
  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
       Navigator.pushNamed(context, '/success');
      } else {
       Navigator.pushNamed(context, '/dashboard');
      }
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
              , id: 0,title: 'Compose New Record')))
          .then((value) =>
          setState(() {}));
    });
  }

  /// This method allows users to access an existing record to edit. The future implementations will prevent timestamps from being edited
  /// Checked and Passed : true
  void _editRecord(int index) {
    setState(() {
      final Records loadRecord = records[index];
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ComposeRecordsWidget(
              record: loadRecord, id: 1,title: 'Edit Record',)))
          .then((loadRecord) =>
          setState(() {}));
    });
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
             }
            );
            },
          ),
      ],
      ),
      body: Column(key: UniqueKey(),
        children: <Widget>[
          SizedBox(
            height: 20,
          ),Padding(
            padding: const EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15, bottom: 0),
            child:Row(children:[Expanded(child: Text(
              'Welcome back $greeting! What would you like to record today?',
              style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center,),),],
             ),
          ),
          Expanded(child: testMe
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('Record'), icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _createRecord();
          }
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        onTap: _onItemTapped,
      ),

    );
  }

}
