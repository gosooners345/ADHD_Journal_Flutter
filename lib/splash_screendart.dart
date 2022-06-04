import 'dart:async';

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import 'main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
late  Database testDB;

  static const platform =
  MethodChannel('com.activitylogger.release1/ADHDJournal');

  bool checkVisitState = false;
  bool transferred = false;
  String dbPassTransfer = "";
  String userPasswordTransfer = "";
  String greetingTransfer = "";
  bool passwordEnabledTransfer = false;
  bool checkTransferred = false;

  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  @override
  void initState() {
    super.initState();
    getPackageInfo();
    // Load prefs and check for previous android shared prefs files
    loadPreferences();
    // if there was a previous db on device, migrate data
if(Platform.isAndroid)
  {
migrateTimer();
  }
    startTimer();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    encryptedSharedPrefs = EncryptedSharedPreferences();
    if(Platform.isAndroid){
      checkVisitState = await databaseExists(Path.join(await getDatabasesPath(),'activitylogger_db.db'));
    }
  }

// This will migrate all data from old shared prefs file to the flutter version.
void migrateData() async {
var checkFirstVisit = false;
    if(checkVisitState){
  checkFirstVisit = prefs.getBool('firstVisit')!;
  if(kDebugMode)
    {
      print(checkFirstVisit);
    }
}

  if (checkFirstVisit) {
    var dbPasswordMigrated = await platform.invokeMethod('migrateDBPassword');
    var userPasswordMigrated = await platform.invokeMethod(
        'migrateUserPassword');
    var passwordPrefs = await platform.invokeMethod('migratePasswordPrefs');
    var greetingMigrated = await platform.invokeMethod('migrateGreeting');
   await prefs.setString('greeting', greetingMigrated);
  await  prefs.setBool('passwordEnabled', passwordPrefs);
    encryptedSharedPrefs.setString('dbPassword', dbPasswordMigrated);
    encryptedSharedPrefs.setString('loginPassword', userPasswordMigrated);
    await prefs.setBool('firstVisit', !checkVisitState);
/*    prefs.reload();
    encryptedSharedPrefs.reload();*/
  }
}
  migrateTimer() async{
    return Timer(Duration(seconds: 2),migrateData);
  }

  startTimer() async {
  var duration = const Duration(seconds: 5);
    return Timer(duration, route);
  }

  void getPackageInfo() async {
     packInfo = await PackageInfo.fromPlatform();
     buildInfo = packInfo.version;
  }

  void route() {
    getPackageInfo();

    var firstVisit = prefs.getBool('firstVisit') ?? true;
    if (firstVisit) {
      Navigator.pushReplacementNamed(( context ), '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  initScreen(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 35,
          ),
         Expanded(child:Image.asset('images/appicon_appstore.png'),),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child:
                Text('Welcome to ADHD Journal! Loading up your journal now...'),
          ),
        ],
      ),
    );
  }
}

late SharedPreferences prefs;
late EncryptedSharedPreferences encryptedSharedPrefs;
late ThemeMode deviceTheme;
late PackageInfo packInfo;
late String buildInfo;