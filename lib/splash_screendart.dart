import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
//import 'package:package_info_plus/package_info_plus.dart';
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
    // Load prefs and check for previous android shared prefs files
    loadPreferences();
    // if there was a previous db on device, migrate data

    startTimer();
  }

  void loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    encryptedSharedPrefs = EncryptedSharedPreferences();
  }

// This will migrate all data from old shared prefs file to the flutter version.

  

  startTimer() async {

  var duration = const Duration(seconds: 5);
    return Timer(duration, route);
  }

  void getPackageInfo() async {
    // packInfo = await PackageInfo.fromPlatform();
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
