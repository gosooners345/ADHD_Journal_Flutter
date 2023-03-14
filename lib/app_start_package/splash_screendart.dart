import 'dart:async';

import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as path;
import 'package:googleapis/drive/v3.dart' as ga;
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
      backArrowIcon = const Icon(Icons.arrow_back);
      nextArrowIcon = Icon(Icons.arrow_forward);
      onboardingBackIcon = Icon(Icons.arrow_back,color: AppColors.mainAppColor);
      onboardingForwardIcon = Icon(Icons.arrow_forward,color: AppColors.mainAppColor);
    } else {
      backArrowIcon = const Icon(Icons.arrow_back_ios);
      nextArrowIcon = const Icon(Icons.arrow_forward_ios);
      onboardingBackIcon = Icon(Icons.arrow_back_ios,color: AppColors.mainAppColor);
      onboardingForwardIcon = Icon(Icons.arrow_forward_ios,color: AppColors.mainAppColor,);
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
      if (kDebugMode) {
        print(ex);
      }
      try {
        await encryptedSharedPrefs.remove('dbPassword');
      } on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
      }
      dbPassword = userPassword;
      await encryptedSharedPrefs.setString('dbPassword', dbPassword);
    }
    if (userPassword != dbPassword) {
      dbPassword = userPassword;
    }
    passwordHint = await encryptedSharedPrefs.getString('passwordHint') ;
    greeting = prefs.getString('greeting') ?? '';
    colorSeed = prefs.getInt("apptheme") ?? AppColors.mainAppColor.value;
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    notificationsAllowed = prefs.getBool('notifications') ?? false;
    isPasswordChecked = passwordEnabled;
    var i =0;
    getNetStatus();
while(connected==false && i<10) {
  await Future.delayed(const Duration(milliseconds: 100));
  i++;
  if (kDebugMode) {
    print(i);
  }
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
     if(Platform.isAndroid){
           checkForAllFiles("");
          }
        }
      }else{
        userActiveBackup = false;
        appStatus.value =
        "To protect your data, you'll need to sign into Google Drive and approve application access to backup your stuff!";
      }

    } else {
      appStatus.value =
      "You have backup and sync disabled! You can enable this on Login "
          "by hitting Sign into Google Drive! You can disable this feature in Settings ";
    }
    appStatus.value = 'Loading up your journal now...';
  }
// This will need to be inclusive
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
  Future<void> checkForAllFiles(String callBack) async{
    print("Check all files called");
    //Check for DB on device
    var checkDB = File(dbLocation);
    //Check for Keys on device
    var checkPrivateKeys = File(
        path.join(keyLocation, privateKeyFileName));
    var checkPublicKeys =  File(path.join(keyLocation, pubKeyFileName));
    //Check for preferences on device
    var checkPrefs = File(docsLocation);
    //Check for Journals file on Google Drive
    var checkJournalFileExist = await Future.sync(() =>googleDrive.checkForFile(driveStoreDirectory));
    if(checkJournalFileExist){
      var checkPrivateKeyOnline = await Future.sync(() =>
          googleDrive.checkForFile(privateKeyFileName));
      var checkPublicKeyOnline= await Future.sync(() =>
          googleDrive.checkForFile(pubKeyFileName));
      //Check for preferences file online
      var checkPrefsOnline = await Future.sync(() =>
          googleDrive.checkForFile(prefsName));
      //Check for DB online
      var checkDBOnline = await Future.sync(
              () =>
              googleDrive.checkForFile(databaseName));
//Condition statements here
      if (checkDB.existsSync() ||
          checkPrefs.existsSync() ||
          checkPrivateKeys.existsSync() && checkPublicKeys.existsSync()) {
        if (checkDBOnline &&
            checkPrefsOnline &&
            checkPrivateKeyOnline&& checkPublicKeyOnline) {
          switch(callBack){
            case "Drive":showDialog(context: context, builder: (BuildContext context){
              return AlertDialog(
              title: Text("Data exists online already"),
              content: Text("It appears you have data online from another device, do you want to download it to this device and overwrite what's already on here?"),
              actions: [ TextButton(
                child: const Text("Yes"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if(checkPublicKeys.existsSync()) {
                    checkPublicKeys.deleteSync();
                  }
                  if(checkPrivateKeys.existsSync()) {
                    checkPrivateKeys.deleteSync();
                  }
                  await Future.sync(() => preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive));
                  if(checkPrefs.existsSync()){
                    checkPrefs.deleteSync();
                    await Future.sync(() => preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive));
                  }
                  if(checkDB.existsSync()){
                    checkDB.deleteSync();
                    await Future.sync(() => restoreDBFiles());
                  }

                },
              ),
                TextButton(onPressed: () async{
                  if(checkPrivateKeys.existsSync() && checkPublicKeys.existsSync()){
                    preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
                  }
                  if(checkPrefs.existsSync()){
                    String dataForEncryption =
                        '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
                        .toString()},$greeting,$colorSeed';
                    if (kDebugMode) {
                      print(
                        "Data is being encrypted and uploaded");
                    }
                    googleIsDoingSomething(true);
                    preferenceBackupAndEncrypt.encryptData(
                        dataForEncryption, googleDrive);
                    googleIsDoingSomething(true);
                  }
                  if(checkDB.existsSync()){
                    uploadDBFiles();
                  }

                }, child: Text("No"))
              ],
            );}); break;
            default: checkFileAge(); break;
          }

          /*checkFileAge();*/

        }
        else {
          if (checkPrivateKeyOnline == false || checkPublicKeyOnline == false) {
            print("Keys aren't online");
            googleIsDoingSomething(true);
            preferenceBackupAndEncrypt
                .encryptRsaKeysAndUpload(googleDrive);
            googleIsDoingSomething(true);
          }
          else if (checkPrivateKeyOnline== true && checkPublicKeyOnline) {
            print("Keys are online");
            await Future.sync(() =>
                preferenceBackupAndEncrypt
                    .downloadRSAKeys(googleDrive));
            print(
                "Keys are being downloaded or are already downloaded onto device");
            googleIsDoingSomething(true);
          }

          if (checkPrefsOnline == false) {
            print("Prefs are not online");
            String dataForEncryption =
                '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
                .toString()},$greeting,$colorSeed';
            print(
                "Data is being encrypted and uploaded");
            googleIsDoingSomething(true);
            preferenceBackupAndEncrypt.encryptData(
                dataForEncryption, googleDrive);
            googleIsDoingSomething(true);
          }
          else if (checkPrefsOnline == true) {
            googleIsDoingSomething(true);
            print(
                "Prefs are online, downloading them to device now");
            await Future.sync(() =>
                preferenceBackupAndEncrypt
                    .downloadPrefsCSVFile(
                    googleDrive));
            googleIsDoingSomething(true);
          }
          if (checkDBOnline == false) {
            await Future.sync(() => uploadDBFiles());
            googleIsDoingSomething(false);
          }
        }
      }
      else{
        print("Keys are not online");
        preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
        googleIsDoingSomething(true);
        print("Prefs are not online");
        String dataForEncryption =
            '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
            .toString()},$greeting,$colorSeed';
        print(
            "Data is being encrypted and uploaded");
        googleIsDoingSomething(true);
        preferenceBackupAndEncrypt.encryptData(
            dataForEncryption, googleDrive);
        googleIsDoingSomething(true);
        showMessage("Preferences Uploaded");
      }
    }
    else{
      print("Creating Journals folder");
      ga.File journalFile = ga.File();
      journalFile.name = driveStoreDirectory;
      var mimetype = "application/vnd.google-apps.folder";
      journalFile.mimeType = mimetype;
      await Future.sync(()=>googleDrive.drive.files.create(journalFile));
      if (checkDB.existsSync() == true ||
          checkPrefs.existsSync() == true ||
          checkPublicKeys.existsSync() == true && checkPrivateKeys.existsSync()==true) {
        googleIsDoingSomething(true);
        if (kDebugMode) {
          print("Uploading keys");
        }
        preferenceBackupAndEncrypt
            .encryptRsaKeysAndUpload(googleDrive);
        if (kDebugMode) {
          print(
              "Data is being encrypted and uploaded");
        }
        String dataForEncryption =
            '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
            .toString()},$greeting,$colorSeed';
        preferenceBackupAndEncrypt.encryptData(
            dataForEncryption, googleDrive);
        if(checkDB.existsSync()==true){
          await Future.sync(() => uploadDBFiles())
              .whenComplete(() =>
              googleIsDoingSomething(false));
        }}
      else {
        if (checkPublicKeys.existsSync() == false || checkPrivateKeys.existsSync()==false) {
          print("Keys aren't online");
          googleIsDoingSomething(true);
          preferenceBackupAndEncrypt
              .encryptRsaKeysAndUpload(googleDrive);
          googleIsDoingSomething(true);
          showMessage("Encryption keys Uploaded");
        }
        if (checkPrefs.existsSync() == false) {
          print("Prefs are not online");
          String dataForEncryption =
              '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
              .toString()},$greeting,$colorSeed';
          print(
              "Data is being encrypted and uploaded");
          googleIsDoingSomething(true);
          preferenceBackupAndEncrypt.encryptData(
              dataForEncryption, googleDrive);
          googleIsDoingSomething(true);
          showMessage("Preferences Uploaded");
        }
        if (checkDB.existsSync() == false) {
          showMessage(
              "You need to open the journal up once to create the DB file for backup & sync");
          googleIsDoingSomething(false);
        }
      }

    }
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
fileCheckAge = await Future.sync(() => googleDrive.checkForFile(databaseName));
if(fileCheckAge == true) {
  fileCheckAge =
  await Future.sync(() => googleDrive.checkFileAge(databaseName, dbLocation));
 if(fileCheckAge == false){
   restoreDBFiles();
 }
}
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
      } on Exception {
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
    print("This is checking for DB Files It is here = $checkDBFile1");
    print(checkDBFile1);
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
bool notificationsAllowed = false;


bool userActiveBackup = false;
GoogleDrive googleDrive = GoogleDrive();
bool isDataSame = true;
late Icon onboardingBackIcon;
late Icon onboardingForwardIcon;

NetworkConnectivity networkConnectivityChecker = NetworkConnectivity.instance;

bool connected = false;