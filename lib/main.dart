// ignore_for_file: prefer_const_constructors

import 'package:adhd_journal_flutter/recordsdatabase_handler.dart';
import 'package:flutter/material.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'records_data_class_db.dart';
import 'login_screen_file.dart';
import 'compose_records_screen.dart';


late RecordsDB recDB;


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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      //home: const MyHomePage(title: 'ADHD Journal'),
      initialRoute: '/',
      routes: {
        '/' : (context) => const LoginScreen(),
        '/success': (context) => const MyHomePage(title: 'ADHD Journal'),
        '/fail': (context) => const LoginScreen()
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

 late Text titleHdr;
 List<Records> _records =[];
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    titleHdr = Text('Home', style: optionStyle);
    _loadTestDB();
  }
  int _selectedIndex = 0;
  String header = "";
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);


  void _onItemTapped(int index) {
    setState(() {
      if(index ==0) {
        titleHdr = Text('Home');
      } else {
        titleHdr = Text('Dashboard');
      }
    });
  }

  void _loadTestDB() async {
    try {
      final data = await RecordsDB.records();
      setState(() {
        _records = data;
      });
      print("Success");
      print(data.length);
    } on Exception catch(err){
      print(err);
    }
  }

  void _createRecord(){
    setState(() {
       titleHdr = Text('Record Created');
       Navigator.push(context, MaterialPageRoute(builder: (context) => ComposeRecords()));
    });
  }

  void _editRecord(){

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              'Welcome back! What would you like to record today?',
            ),
            SizedBox(
              height: 130,
            ),
            Center(child:titleHdr)
          ],
        ),
      ),
    floatingActionButton: FloatingActionButton.extended(label: Text('Record'), icon: Icon(Icons.edit),
      onPressed: () { _createRecord();  },),// This trailing comma makes auto-formatting ni for build methods.
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


///Variables that affect other widgets
