// ignore_for_file: prefer_const_constructors, prefer_final_fields

import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';

late RecordsDB recDB;
List<Records> records = [];
int id =0;
void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        '/' : (context) => const LoginScreen(),
        '/success': (context) => const MyHomePage(title: 'ADHD Journal'),
        '/fail': (context) => const LoginScreen(),
        
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);


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
                          child: ListTile(
                            onTap: () {
                              _editRecord(index);
                            },
                            title: Text(records[index].toString(),),
                          )
                      ),
                      onHorizontalDragEnd: (_) {
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


  /// This loads the db list into the application for displaying.
  void getList() async {
    _recordList = RecordsDB.records();
  }


  /// This is for the bottom navigation bar, this isn't related to the records at all.
  void _onItemTapped(int index) {
    setState(() {
      if (index == 0) {
        titleHdr = Text('Home');
      } else {
        titleHdr = Text('Dashboard');
      }
    });
  }

  /// Allows users to create entries for the db and journal. Once submitted, the screen will update on demand.
  /// Checked and passed : true
  void _createRecord() {
    setState(() {
      titleHdr = Text('Record Created');
      //id = records[records.length - 1].id + 1;
      if(records.isEmpty) {
        id =1;
      } else {
        id = records[records.length - 1].id + 1;
      }
      Navigator.push(context, MaterialPageRoute(builder: (_) =>
          ComposeRecordsWidget(
              record: Records(id: id, title: '', content: '',emotions: ''), id: 0)))
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
              record: loadRecord, id: 1)))
          .then((loadRecord) =>
          setState(() {}));
    });
  }
  /// This compiles the screen display for the application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(key: UniqueKey(),
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'Welcome back! What would you like to record today?',
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
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),

    );
  }

}
