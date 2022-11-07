import 'dart:async';

import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:package_info/package_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../project_resources/network_connectivity_checker.dart';
import '../drive_api_backup_general/google_drive_backup_class.dart';
import 'login_screen_file.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late Database testDB;


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
      nextArrowIcon = Icon(Icons.arrow_forward,color: AppColors.mainAppColor,);
      onboardingBackIcon = Icon(Icons.arrow_back,color: AppColors.mainAppColor);
    } else {
      backArrowIcon = Icon(Icons.arrow_back_ios);
      onboardingBackIcon = Icon(Icons.arrow_back_ios,color: AppColors.mainAppColor);
      nextArrowIcon = Icon(Icons.arrow_forward_ios,color: AppColors.mainAppColor,);
    }
    appStatus.value =
    "Welcome to ADHD Journal! We're getting your stuff ready!";
    networkConnectivityChecker.initialise();
    getNetStatus();
    finishTimer();
  }

  void loadPreferences() async {
    bool isClientActive = true;
    appStatus.value = "Getting preferences now";
    prefs = await SharedPreferences.getInstance();
    encryptedSharedPrefs = EncryptedSharedPreferences();
    userPassword = await encryptedSharedPrefs.getString('loginPassword');
    try {
      dbPassword = await encryptedSharedPrefs.getString('dbPassword');
    } on Exception catch (ex) {
      print(ex);
      try {
        await encryptedSharedPrefs.remove('dbPassword');
      } on Exception catch (ex) {
        print(ex);
      }
      dbPassword = userPassword;
      await encryptedSharedPrefs.setString('dbPassword', dbPassword);
    }
    if (userPassword != dbPassword) {
      dbPassword = userPassword;
    }
    passwordHint = await encryptedSharedPrefs.getString('passwordHint') ?? '';
    greeting = prefs.getString('greeting') ?? '';
    colorSeed = prefs.getInt("apptheme") ?? AppColors.mainAppColor.value;
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    isPasswordChecked = passwordEnabled;
    var i =0;
    getNetStatus();
while(connected==false && i<10){
await Future.delayed(Duration(milliseconds: 100));
i++;
print(i);
}
// Give option to work around if user doesn't want to use Google Drive before publishing update
    if(connected==true){
      userActiveBackup = prefs.getBool('testBackup')??false;

    }
    if (userActiveBackup) {
      appStatus.value =
      "You have backup and sync enabled! Checking for new files";
      appStatus.value = "Signing into Google Drive!";
      googleDrive = GoogleDrive();
      googleDrive.client =
      await Future.sync(() =>  googleDrive.getHttpClient());

      readyButton.boolSink.add(true);

      if(isClientActive==true|| googleDrive.client!=null){
        if(userActiveBackup){
          checkFileAge();
        }
        else{
          isDataSame = true;
        }
      }else{
        userActiveBackup = false;
        appStatus.value =
        "To protect your data, you'll need to sign into Google Drive and approve application access to backup your stuff!";
      }

    } else {
      appStatus.value =
      "You have backup and sync disabled! You can enable this on Login "
          "by hitting Add to Drive! You can disable this feature in Settings ";
    }



    appStatus.value = 'Loading up your journal now...';
  }

  void googleIsDoingSomething(bool value) {
    readyButton.boolSink.add(value);
  }

  finishTimer() async {
    var duration = const Duration(seconds: 7);
    getPackageInfo();
    loadPreferences();
    return Timer(duration, route);
  }

  void getNetStatus(){
    networkConnectivityChecker.myStream.listen((source) {
      if(source==true){
        connected =true;
      }
    }).onData((data)   {
      if(data==false){
        userActiveBackup = false;
        connected = false;
      }
      else{

        appStatus.value = "You're connected to a network, we can backup and sync your files if you turned backup and sync on.";
        connected = true;
      }
    });

  }
  void getPackageInfo() async {
    appStatus.value = "Getting Build and App Version info";
    packInfo = await PackageInfo.fromPlatform();
    buildInfo = packInfo.version;
    String docDirectory = await Future.sync(() => getDatabasesPath());
    dbLocation = path.join(docDirectory, databaseName);
    docsLocation = path.join(docDirectory, prefsName);
    keyLocation = docDirectory;
  }

  void checkFileAge() async {
    appStatus.value =
        "Checking for updated files... \r\nThanks for your patience";
    print("Splashscreen Check File Age Called");
    readyButton.boolSink.add(true);
    File dbFile = File(dbLocation);
    File privateKeyFile = File(path.join(keyLocation, privateKeyFileName));
    File prefsFile = File(docsLocation);
    String dataForEncryption =
        '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
    bool fileCheckAge = false;

    fileCheckAge = await Future.sync(() => googleDrive.checkFileAge(databaseName,dbLocation));

    bool checkOnlineKeys =
        await Future.sync(() => googleDrive.checkForFile(privateKeyFileName));
    bool checkKeyAge = await Future.sync(
        () => googleDrive.checkFileAge(privateKeyFileName,privateKeyFile.path));
    if ( checkOnlineKeys ||
        checkKeyAge == true) {
      readyButton.boolSink.add(true);
      await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
      preferenceBackupAndEncrypt.assignRSAKeys(googleDrive);
    } else if (!privateKeyFile.existsSync() && !checkOnlineKeys) {
      preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
    } else {
      preferenceBackupAndEncrypt.assignRSAKeys(googleDrive);
    }
    bool checkPrefsEncryptedFile =
        await googleDrive.checkForFile(prefsName);
    bool txtFileChange = false;
    if (checkPrefsEncryptedFile) {
      txtFileChange = await googleDrive.checkFileAge(prefsName,docsLocation);
      if (txtFileChange) {
        preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
      } else {
        readyButton.boolSink.add(true);
        await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
        if (dataForEncryption == decipheredData) {
          isDataSame = true;
          appStatus.value =
              "Don't worry about waiting when things are done loading!";
          //  });
        } else {
          readyButton.boolSink.add(true);
          isDataSame = false;
          appStatus.value = "Your data will need to be synced before you login";
        }
      }
    } else {
      try {
        appStatus.value =
            "Syncing preferences with Google Drive for your other devices to sync up when they connect!";
        if (prefsFile.existsSync()) {
          prefsFile.deleteSync();
          preferenceBackupAndEncrypt.encryptData(
              dataForEncryption, googleDrive);
        }
      } on Exception catch (ex) {
        readyButton.boolSink.add(true);
        await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
        if (dataForEncryption == decipheredData) {
          isDataSame = true;
        } else {
          isDataSame = false;
        }
      }
    }
    bool checkDBFile1 = await googleDrive.checkForFile(databaseName);
    bool checkDBFile2 = await googleDrive.checkForFile(dbWal);
    if (checkDBFile1 || checkDBFile2) {
      if (!dbFile.existsSync() || !fileCheckAge) {
        readyButton.boolSink.add(true);
        await Future.sync(() => restoreDBFiles().whenComplete(() => {
              if (kDebugMode)
                {
                  print("Download done"),
                },
              appStatus.value = "Your Journal is synced on device now",
              readyButton.boolSink.add(false)
            }));
      } else {
        readyButton.boolSink.add(true);
        await Future.sync(() => uploadDBFiles().whenComplete(() => {
              if (kDebugMode)
                {
                  print("Upload done"),
                },
              appStatus.value = "Your Journal is synced online now",
              readyButton.boolSink.add(false),
              readyButton.boolSink.add(false)
            }));
      }
    } else if (dbFile.existsSync()) {
      readyButton.boolSink.add(true);
      await uploadDBFiles();
      readyButton.boolSink.add(false);
    } else {
      appStatus.value =
          "You need to create a database for use in this application";
    }
  }

  Future<void> restoreDBFiles() async {
    try {
      readyButton.boolSink.add(true);
      appStatus.value = downloading_journal_files_message_string;
      await Future.sync(() => googleDrive.syncBackupFiles(
         databaseName));
    } on Exception catch (ex) {
      showMessage(ex.toString());
    }
  }

  Future<void> uploadDBFiles() async {
    appStatus.value = "Uploading updated journal files";
    try {
      readyButton.boolSink.add(true);
      googleDrive.deleteOutdatedBackups(databaseName);
      googleDrive.uploadFileToGoogleDrive(File(dbLocation));
      googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
      googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
      await Future.delayed(
          const Duration(seconds: 1), () => readyButton.boolSink.add(false));
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void route() {
    var firstVisit = prefs.getBool('firstVisit') ?? true;
    if (firstVisit) {
      appStatus.value = first_time_user_intro_string;
      Navigator.pushReplacementNamed((context), '/onboarding');
    } else {
      appStatus.value = "Loading Login Screen Now!";
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
          Expanded(
            child: Image.asset('images/appicon_appstore.png'),
          ),
          Padding(
            padding: EdgeInsets.all(20.0),
            child: ValueListenableBuilder(
                valueListenable: appStatus,
                builder: (BuildContext builder, String value, Widget? child) {
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
late Icon nextArrowIcon;
String passwordHint = '';
int colorSeed = AppColors.mainAppColor.value;
late ThemeData lightTheme;
late ThemeData darkTheme;
String dbLocation = "";
String docsLocation = "";
String keyLocation = "";



bool userActiveBackup = false;
GoogleDrive googleDrive = GoogleDrive();
bool isDataSame = true;
late Icon onboardingBackIcon;
NetworkConnectivity networkConnectivityChecker = NetworkConnectivity.instance;

bool connected = false;