import 'dart:async';

import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:adhd_journal_flutter/drive_api_backup_general/preference_backup_class.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:package_info/package_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

import '../drive_api_backup_general/google_drive_backup_class.dart';
import 'login_screen_file.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
late  Database testDB;
ConnectivityResult? _connectivityResult;
late StreamSubscription _connectivitySubscription;
  static const platform =
  MethodChannel('com.activitylogger.release1/ADHDJournal');

  bool checkVisitState = false;
  bool transferred = false;
  String dbPassTransfer = "";
  String userPasswordTransfer = "";
  String greetingTransfer = "";
  bool passwordEnabledTransfer = false;
  bool checkTransferred = false;

  Text statusUpdateWidget = Text('');
ValueNotifier<String> appStatus = ValueNotifier("");
  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      backArrowIcon = Icon(Icons.arrow_back);
    } else {
      backArrowIcon = Icon(Icons.arrow_back_ios);
    }
    appStatus.value= "Welcome to ADHD Journal! We're getting your stuff ready!";

    // Load prefs and check for previous android shared prefs files

   finishTimer();

  }

  Future<bool> _checkConnState() async{
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if(result ==ConnectivityResult.wifi || result == ConnectivityResult.mobile){
      return true;
    }
    else{
      return false;
    }
  }

  void loadPreferences() async {

appStatus.value= "Getting preferences now";
    prefs = await SharedPreferences.getInstance();
    encryptedSharedPrefs = EncryptedSharedPreferences();
    userPassword = await encryptedSharedPrefs.getString('loginPassword');
    try{
dbPassword = await encryptedSharedPrefs.getString('dbPassword');}
    on Exception catch(ex){
      print(ex);
      try {
        await encryptedSharedPrefs.remove('dbPassword');
      } on Exception catch(ex){
        print(ex);
      }
      dbPassword = userPassword;
      await encryptedSharedPrefs.setString('dbPassword', dbPassword);
    }
if(userPassword != dbPassword){
  dbPassword = userPassword;
}
passwordHint = await encryptedSharedPrefs.getString('passwordHint')??'';
greeting = prefs.getString('greeting') ?? '';
colorSeed = prefs.getInt("apptheme") ?? AppColors.mainAppColor.value;
passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    isPasswordChecked = passwordEnabled;
    userActiveBackup = prefs.getBool('testBackup') ?? false;
    swapper = ThemeSwap();
    swapper?.themeColor = prefs.getInt("apptheme") ?? AppColors.mainAppColor.value;
//var testConnection = await _checkConnState();

    if(userActiveBackup){
      try{
        appStatus.value = "You have backup and sync enabled! Checking for new files";
//if(testConnection) {
  googleDrive = GoogleDrive();
  googleDrive.init();

  googleDrive.client = await googleDrive.getHttpClientSilently();
  if (googleDrive.client == null) {
    userActiveBackup = false;
  }
  if (userActiveBackup) {
    checkFileAge();
  }
  else { //Failsafe
    isDataSame = true;
  }
//}
/*else {
  appStatus.value = "You need to be connected to Mobile Data or Wifi to sync your journal";
  userActiveBackup = false;
}*/
      }on Exception catch(ex){
        showMessage(ex.toString());
        userActiveBackup = false;
      }
    } else{
     appStatus.value = "You have backup and sync disabled! You can enable this on Login "
          "by hitting Add to Drive! You can disable this feature in Settings ";
    }
   appStatus.value = 'Loading up your journal now...';
  }

  finishTimer() async {
  var duration = const Duration(seconds: 8);
  getPackageInfo();
  loadPreferences();
    return Timer(duration, route);
  }
  void getPackageInfo() async {
   appStatus.value= "Getting Build and App Version info";
     packInfo = await PackageInfo.fromPlatform();
     buildInfo = packInfo.version;
    String docDirectory = await Future.sync(() => getDatabasesPath());
     dbLocation = path.join(docDirectory,'activitylogger_db.db');
 docsLocation = path.join(docDirectory,'journalStuff.txt');
 keyLocation = docDirectory;
  }

  void checkFileAge() async{
    appStatus.value = "Checking for updated files... \r\nThanks for your patience";

    File dbFile = File(dbLocation);
    File privateKeyFile = File(path.join(keyLocation,"journ_privkey.pem"));
    File prefsFile = File(docsLocation);
    String dataForEncryption = '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
      bool fileCheckAge = false;
      try{
        fileCheckAge = await Future.sync(() =>  googleDrive.checkDBFileAge(dbWal));
      } on Exception catch(ex){
        fileCheckAge = await Future.sync(()=>googleDrive.checkDBFileAge(dbName));
      }
      bool checkOnlineKeys = await Future.sync(()=>googleDrive.checkForFile('journ_privkey.pem'));
      if(!privateKeyFile.existsSync() && checkOnlineKeys){
        await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
      }
      else if(!privateKeyFile.existsSync() && !checkOnlineKeys){
        preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
      }
      else{
        preferenceBackupAndEncrypt.assignRSAKeys(googleDrive);
      }
      bool checkPrefsEncryptedFile = await googleDrive.checkForFile(prefsTransportName);
      bool txtFileChange = false;
      if(checkPrefsEncryptedFile){
        txtFileChange = await googleDrive.checkCSVFileAge(prefsTransportName);
        if(txtFileChange){
          preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
        }
        else{
         await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
          if(dataForEncryption == decipheredData){
            isDataSame = true;
          } else{
            isDataSame = false;
          }
        }
      } else{
      try{
        if(prefsFile.existsSync()){
          prefsFile.deleteSync();
        preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
        }
      }
       on Exception catch(ex){
         await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
          if(dataForEncryption == decipheredData){
            isDataSame = true;
          }          else{
            isDataSame = false;
          }

        }
        prefs.setBool('isDataSame', isDataSame);
      }
      bool checkDBFile1 = await googleDrive.checkForFile(dbName);
      bool checkDBFile2 = await googleDrive.checkForFile(dbWal);
      if(checkDBFile1 || checkDBFile2){
        if(!dbFile.existsSync()|| !fileCheckAge){
 await Future.sync(() =>  restoreDBFiles().whenComplete(() => {
   if(kDebugMode){
     print("Download done"),
   },
appStatus.value = "Your Journal is synced on device now",
 }));
        }
        else{
          await Future.sync(() => uploadDBFiles().whenComplete(() =>{
            if(kDebugMode){
              print("Upload done"),
            },
            appStatus.value = "Your Journal is synced online now",
          }));

        }
      }
      else if(dbFile.existsSync()){
        await uploadDBFiles();
      }
      else{
        showMessage("You need to create a database for use in this application");
      }
    }
Future<void> restoreDBFiles() async {
  try {
    appStatus.value = "Downloading updated journal files";
  await Future.sync(()=>googleDrive.syncBackupFiles("activitylogger_db.db"));
  } on Exception catch (ex) {
showMessage(ex.toString());
  }
}
Future<void> uploadDBFiles() async {
    appStatus.value = "Uploading updated journal files";
  try {
    googleDrive.deleteOutdatedBackups("activitylogger_db.db");
    googleDrive.uploadFileToGoogleDrive(File(dbLocation));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
  } on Exception catch(ex){
    print(ex);
  }
}
  void showMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:Text(message),
        ));
  }

  void route() {

    var firstVisit = prefs.getBool('firstVisit') ?? true;
    if (firstVisit) {
      appStatus.value= "This is your first time using this application. "
          "\r\nLet's get you started!";
      Navigator.pushReplacementNamed((context), '/onboarding');
    } else {
      appStatus.value ="Loading Login Screen Now!";
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
         Padding(
            padding: EdgeInsets.all(20.0),
            child:ValueListenableBuilder( valueListenable: appStatus,
        builder:(BuildContext builder,String value,Widget? child){
              return Text(value);
        }),

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
late Icon backArrowIcon;
String passwordHint = '';
int colorSeed =AppColors.mainAppColor.value;
late ThemeData lightTheme;
late ThemeData darkTheme;
String dbLocation = "";
String docsLocation = "";
String keyLocation ="";
String dbName = "activitylogger_db.db";
String dbWal = "activitylogger_db.db-wal";
String prefsTransportName = "journalStuff.txt";
bool userActiveBackup = false;
GoogleDrive googleDrive = GoogleDrive();
bool isDataSame = true;
ThemeSwap? swapper;