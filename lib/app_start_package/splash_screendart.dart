import 'dart:async';
import 'dart:convert';

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
import '../backup_utils_package/crypto_utils.dart';
import '../project_resources/file_manager_helper.dart';
import '../project_resources/network_connectivity_checker.dart';
import '../backup_providers/google_drive_backup_class.dart';

import 'login_screen_file.dart';

// Splash Screen Class for application. This page will need examined for performance improvement potential

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, this.swapper}) : super(key: key);
  final ThemeSwap? swapper;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
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

  Text statusUpdateWidget = const Text('');
  ValueNotifier<String> appStatus = ValueNotifier("");

  @override
  Widget build(BuildContext context) {
    return initScreen(context);
  }

  @override
  void initState() {
    super.initState();

    networkConnectivityChecker.initialise();
//Icon Assignments
    if (Platform.isAndroid) {
 /*     if (kDebugMode) {
        redirectOneDriveURL = oneDriveAndroidProdRedirect;
      } else {
        redirectOneDriveURL = oneDriveAndroidProdRedirect;
      }*/
      backArrowIcon = const Icon(Icons.arrow_back);
      nextArrowIcon = const Icon(Icons.arrow_forward);
      onboardingBackIcon =
          Icon(Icons.arrow_back, color: AppColors.mainAppColor);
      onboardingForwardIcon =
          Icon(Icons.arrow_forward, color: AppColors.mainAppColor);
    }
    else{
      //redirectOneDriveURL = oneDriveiOSRedirect;
      backArrowIcon = const Icon(Icons.arrow_back_ios);
      nextArrowIcon = const Icon(Icons.arrow_forward_ios);
      onboardingBackIcon =
          Icon(Icons.arrow_back_ios, color: AppColors.mainAppColor);
      onboardingForwardIcon = Icon(
        Icons.arrow_forward_ios,
        color: AppColors.mainAppColor,
      );
    }
    appStatus.value =
        "Welcome to ADHD Journal! We're getting your stuff ready!";

    getNetStatus();
    finishTimer();
  }
  finishTimer() async {
    setState(() {
      appStatus.value = "Getting Build and App Version info";
    });

await initPrefs().whenComplete(()async {

      if(googleDrive.client==null){
        googleDrive.initVariables();
        if(googleDrive.client!=null){
          print("Google Drive client is not null");
          //break;
        }
        else{
          print("Google Drive client is null");
        }
      }
      await getPackageInfo().whenComplete(() =>
          loadPreferences().whenComplete(() {
            checkGoogleDrive();
          }));

      if(kDebugMode){
        if(fileCheckCompleted==true){
          print("File check completed");
        }else{
          print("File check not completed");
  //      }
      }
    }});
    //await loadPreferences();

    //print("done");
  //}).whenComplete(()async {
   // print("Checking Google Drive");
    //await checkGoogleDrive();
  //}).whenComplete(()async {
    Future.delayed(Duration(seconds: 10), route);//});

   //await loadPreferences();
  //await checkPreferences();
//  await checkGoogleDrive();
    //getPackageInfo();
    // see if these can be futures and then chained in await statements to hold up UI for all transactions to complete.
    //for IOS



  }
 Future<void> initPrefs() async{
    appStatus.value = "Loading preferences now";
    prefs = await SharedPreferences.getInstance();
   try{
    encryptedSharedPrefs = EncryptedSharedPreferences();
    print("prefs not null currently");
    while(encryptedSharedPrefs == null){
      await Future.delayed(const Duration(milliseconds: 100));
      print("prefs null currently");
      encryptedSharedPrefs = EncryptedSharedPreferences();
    }
    //Testing google sign in
    if (connected == true) {
      userActiveBackup = prefs.getBool('testBackup') ?? false;
      print("Backup is turned on: $userActiveBackup");
    }
    //await Future.delayed(Duration(seconds: 2));
   // do {
    try{
      print("SplashScreen Sign in called");
      googleDrive.initVariables();
   //   print("Intialized google drive variables");
    }
    on Exception catch(ex){
      if(kDebugMode){
        print(ex);
      }
      print("Backup google sign in called");
      googleDrive.client = await  googleDrive.getHttpClient();
      googleDrive.initV2();
    }
    while(googleDrive.client==null){
      await Future.delayed(const Duration(seconds:2),(){
        print("Delay loading for sign in to complete");
      });
if(googleDrive.client!=null){
  break;
}
    }



   }on Exception catch(ex){
     print(ex);
   }


  }

 Future< void> loadPreferences() async {
    print("Loading Prefs");
    var tempHint = await encryptedSharedPrefs.getString('passwordHint')??"";
    userPassword = await encryptedSharedPrefs.getString('loginPassword');
    bool didThingsChange=false;
    // Strange bug in 2022 with out of range exception being thrown, this code was written to catch it.
    try {
      dbPassword = await encryptedSharedPrefs.getString('dbPassword');
    }
    on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      //Database password has to be handled with extra care because it unlocks the journal.
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
    // In case if the db password and user password don't match. Be careful with this.
    if (userPassword != dbPassword) {
      //test open DB in case dbPassword is correct.
      //Try changing passwords and see if they result in the correct outcome.
      try{
        final testDB = await openDatabase( dbLocation, password: dbPassword);
        if(kDebugMode){
          print("Testing Open of journal");
        }
        if(testDB.isOpen){
          if (kDebugMode) {
            print("DB Password is correct, do not change the password");
          }
          ///Set login password to DB password because it was successful.
          userPassword = dbPassword;
          await testDB.close().whenComplete(()=>
           encryptedSharedPrefs.remove('loginPassword').whenComplete(()=>
           encryptedSharedPrefs.setString('loginPassword', userPassword)));
          //Temp hint to replace logged one due to password change.
          tempHint = "Use $dbPassword to login";
          await encryptedSharedPrefs.setString('passwordHint', tempHint);
          didThingsChange = true;

        } else{
          throw Exception("DB is not open, db password is incorrect");
        }
      }
      on Exception catch (ex) {
        if (kDebugMode) {
          print(ex);
        }
        dbPassword = userPassword;
        await encryptedSharedPrefs.setString('dbPassword', dbPassword);
        didThingsChange = true;
      }
    }
    if(didThingsChange){
      await encryptedSharedPrefs.reload().whenComplete(() async {
      userPassword = await encryptedSharedPrefs.getString('loginPassword');
      dbPassword = await encryptedSharedPrefs.getString('dbPassword');
      });
      await prefs.reload();
    }

    passwordHint = await encryptedSharedPrefs.getString('passwordHint');
    greeting = prefs.getString('greeting') ?? '';
    colorSeed = prefs.getInt("apptheme") ?? AppColors.mainAppColor.value;
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    notificationsAllowed = prefs.getBool('notifications') ?? false;
    isPasswordChecked = passwordEnabled;
    //Move code below to another method.
 //   var i = 0;
    //getNetStatus(); Unnecessary code due to the call in initState()
    /*while (connected == false && i < 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      i++;
      if (kDebugMode) {
        print(i);
      }
    }*/
// Give option to work around if user doesn't want to use Google Drive before publishing update

  }
  //Check to see if passwords were changed since last login.
  //Update passwords if needed.

  Future<bool> checkPreferences() async {
    File preferencesFile = File(docsLocation);
    String decipheredData = CryptoUtils.rsaDecrypt(preferencesFile.readAsStringSync(
      encoding: Encoding.getByName("utf-8")!),preferenceBackupAndEncrypt.privKey!);

    String dataForEncryption =
        '$userPassword,$dbPassword,$passwordHint,${passwordEnabled
        .toString()},$greeting,$colorSeed';
    googleIsDoingSomething(true);
    if (dataForEncryption == decipheredData) {
      setState(() {
        appStatus.value = "Preferences are up to date";
      });
      return true;
    }
    else {
      setState(() {
        appStatus.value =
        "Preferences are out of date, we will need to update the local version.";
      });
      return false;
    }
  }

//Missing Color seed prefs.
  Future<void> updatePreferences() async{
    File preferencesFile = File(docsLocation);
    var tempHint="";
    String decipheredData = CryptoUtils.rsaDecrypt(preferencesFile.readAsStringSync(
        encoding: Encoding.getByName("utf-8")!),preferenceBackupAndEncrypt.privKey!);
    String newLoginPW="", newDBPW="", newHint="", newGreeting="";
    int newColorSeed =0;
    bool  newEnabled=false;
    var newVals = decipheredData.split(",");
    newLoginPW = newVals[0];
    newDBPW = newVals[1];
    newHint = newVals[2];
    newEnabled = newVals[3] == "true" ? true : false;;
    newGreeting = newVals[4];
    newColorSeed = int.parse(newVals[5]);
if(kDebugMode){
  print("Changing Values");
}
appStatus.value = "Updating Preferences";
if(newLoginPW != userPassword || newDBPW != dbPassword){
  try{
    final testDB = await openDatabase( dbLocation, password: newDBPW);
    userPassword = newLoginPW;
    if(kDebugMode){
      print("Testing Open of journal");
    }
    if(testDB.isOpen){
      dbPassword = newDBPW;
      if (kDebugMode) {
        print("DB Password is correct, do not change the password");
      }
      ///Set login password to DB password because it was successful.
      userPassword = dbPassword;
      await testDB.close().whenComplete(()=>
          encryptedSharedPrefs.remove('loginPassword').whenComplete(()=>
              encryptedSharedPrefs.setString('loginPassword', userPassword)));
      //Temp hint to replace logged one due to password change.
      tempHint = "Use $dbPassword to login";
      await encryptedSharedPrefs.setString('passwordHint', tempHint);
     // didThingsChange = true;

    } else{
      throw Exception("DB is not open, db password is incorrect");
    }
  }
  on Exception catch (ex) {
    if (kDebugMode) {
      print(ex);
    }
    dbPassword = userPassword;
    await encryptedSharedPrefs.setString('dbPassword', dbPassword);
  //  didThingsChange = true;
  }
}
  if(newHint != passwordHint){
    passwordHint = newHint;
    await encryptedSharedPrefs.setString('passwordHint', passwordHint);
  }
  if(newEnabled != passwordEnabled){
    passwordEnabled = newEnabled;
    await prefs.setBool('passwordEnabled', passwordEnabled);
  }
    if (greeting != newGreeting) {
      greeting = newGreeting;
      prefs.setString('greeting', greeting);
    }
    if (colorSeed != dlColorSeed) {
      colorSeed = dlColorSeed;
      prefs.setInt('apptheme', colorSeed);
      setState(() {
        super.widget.swapper?.themeColor = colorSeed;
      });
    }
    await encryptedSharedPrefs.reload();
    prefs.reload();

  }
  //Call before doing anything with update preferences.
 Future<void> checkGoogleDrive() async{
   /*if (connected == true) {
     userActiveBackup = prefs.getBool('testBackup') ?? false;
     print("Backup is turned on: $userActiveBackup");
   }*/
   if (userActiveBackup) {

       appStatus.value = "You have backup and sync enabled! Signing into Google Drive!";

    /* try{
       googleDrive.initVariables();
       print("Intialized google drive variables");
     }
     on Exception catch(ex){
       if(kDebugMode){
         print(ex);
       }
       googleDrive.client = await  googleDrive.getHttpClient();
       googleDrive.initV2();
     }*/
     googleIsDoingSomething(true);
     if (googleDrive.client != null) {
       if (userActiveBackup) {
   ///See if we can unify this code to only execute once.
     ///    if (Platform.isAndroid) {

         print("Checking Keys");
         await checkFilesExistV2(path.join(keyLocation, privateKeyFileName), privateKeyFileName, "Keys").whenComplete(()
async {

         await checkFilesExistV2(path.join(keyLocation, pubKeyFileName), pubKeyFileName, "Keys");
         print("Checking Journal");
         await checkFilesExistV2(dbLocation, databaseName, "Journal");
print("Checking Preferences");
         await checkFilesExistV2(docsLocation, prefsName, "Preferences");});//3x

         }
       }
      else {
       userActiveBackup = false;
       appStatus.value =
       "To protect your data, you'll need to sign into Google Drive and approve application access to backup your stuff!";
     }
   }
   else {
     appStatus.value =
     "You have backup and sync disabled! You can enable this on Login "
         "by hitting Sign into Google Drive! You can disable this feature in Settings ";
   }
   appStatus.value = 'Loading up your journal now...';
 }
  void googleIsDoingSomething(bool value) {
    readyButton.boolSink.add(value);
  }
/// Handles loading application stuff at top level. Break as much down as possible to improve code control.


  void getNetStatus() {
    networkConnectivityChecker.myStream.listen((source) {
      if (source == true) {
        connected = true;
      }
    }).onData((data) {
      if (data == false) {
        userActiveBackup = false;
        connected = false;
        appStatus.value =
            "You're not connected to a network, we can't backup and sync your journal.";
      } else {
        appStatus.value =
            "You're connected to a network, we can backup and sync your journal if you turned backup and sync on.";
        connected = true;
      }
    });
  }
//Improved error handling, unlikely this would trigger exceptions, but wanted to be safe.
 Future< void> getPackageInfo() async {
    packInfo = await PackageInfo.fromPlatform();
    buildInfo = packInfo.version;
    try {
      String docDirectory = await getDatabasesPath();
    if(docDirectory==""){
      docDirectory = await Future.delayed(const Duration(seconds: 1), (){
        return getDatabasesPath();
      });
      if(docDirectory==""){
        throw Exception("Could not get database path");
      }
    }
      else{
      dbLocation = path.join(docDirectory, databaseName);
      docsLocation = path.join(docDirectory, prefsName);
      keyLocation = docDirectory;
    }
    } on Exception catch(ex){
    setState(() {
      appStatus.value = "Could not get database path";
    });
 if(kDebugMode){
        print(ex);}
    }
  }
/// This method is responsible for checking the status of files and age of data on both sides.
  Future<void> checkFilesExistV2(String localFileName,String remoteFileName, String fileType)async{
    var fileChecker = ManagedFile(localFileName,remoteFileName);
   //Check for existence of files and age.
    print("Checking $fileType");
    await fileChecker.checkLocalExistence();
    await fileChecker.checkRemoteExistence(googleDrive);
     await fileChecker.checkRemoteIsNewer(googleDrive);
    //Check file existence first locally then remotely. If file exists in cloud, but not on device, then download it.
    //Done
    if(!fileChecker.localExists){
  //Check if file exists on cloud.
  if(!fileChecker.remoteExists){
    if(kDebugMode) {
      print("File does not exist on device or cloud");
    }
        appStatus.value = "$fileType does not exist on device or cloud";
        appStatus.value = "You will need to open the journal to create the file";


  } //Download if exists in cloud.
  else{
    if(kDebugMode){
      print("File exists on cloud but not on device");
    }

      appStatus.value = "$fileType exists on cloud but not on device";
      appStatus.value = "Downloading $fileType now";

    //Use Switch Case statement to handle file delivery
    switch (fileType) {
      case "Journal":
        await restoreDBFiles();
        break;
      case "Preferences":
        await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive).whenComplete((){
           updatePreferences();
        });
        //Process file.
        break;
      case "Keys":
        await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
        break;
    }
  }

}
    //If cloud copy doesn't exist, then we can upload it.
if(!fileChecker.remoteExists && fileChecker.localExists){
  if(kDebugMode){
    print("$fileType exists on device but does not exist on device or cloud, uploading to Drive");}
    setState(() {
      appStatus.value = "$fileType does not exist on device or cloud";
    });
    //use switch case statement to handle file delivery, uploading here
  switch (fileType) {
    case "Journal":
      await uploadDBFiles();
      break;
    case "Preferences":
      String dataForEncryption =
          '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
      googleIsDoingSomething(true);
      await preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive).whenComplete(() {
        setState(() {
          appStatus.value = "Preferences Uploaded";
        });
        googleIsDoingSomething(false);});

      break;
    case "Keys":
      await preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive).whenComplete(() {
        setState(() {
          appStatus.value = "Encryption keys Uploaded";
        });
        googleIsDoingSomething(false);
      });
      break;
  }
}
if(fileChecker.localExists && fileChecker.remoteExists){
  if(fileChecker.localIsNewer!){
//In future update, integrate file IDs
      appStatus.value = "$fileType exists on device and cloud but is newer on device. Replacing file in cloud with new local copy.";
    //Use switch case statement to handle file delivery,
    switch (fileType) {
      // Future update integrate DB ID to reduce frequency of double uploading
      case "Journal":
        await uploadDBFiles();
        break;
      case "Preferences":
        String dataForEncryption =
            '$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
        googleIsDoingSomething(true);
        await preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive).whenComplete(() {
          setState(() {
            appStatus.value = "Preferences Uploaded";
          });
          googleIsDoingSomething(false);});
        break;
      case "Keys":
        await preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive).whenComplete(() {
          setState(() {
            appStatus.value = "Encryption keys Uploaded";
          });
          googleIsDoingSomething(false);
        });
        break;
    }
  }
  else{
      appStatus.value = "$fileType exists on device and cloud but is newer on cloud";
      appStatus.value = "Downloading updated $fileType now";
    googleIsDoingSomething(true);
    //Use switch case statement to handle file delivery
    switch (fileType) {
      case "Journal":
        await restoreDBFiles().whenComplete(() {
            appStatus.value = "Journal Updated";
        });
        googleIsDoingSomething(false);
        break;
      case "Preferences":
        await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive).whenComplete(() {
appStatus.value = "Updated preferences downloaded, checking for mismatches";

        });
        final isDataSame = await checkPreferences();
        if(!isDataSame){
          appStatus.value = "Preferences are out of date, we will need to update the local version.";
          await updatePreferences().whenComplete(() {
            appStatus.value = "Preferences Updated";
          });
        }
        else{appStatus.value = "Preferences are up to date";}
googleIsDoingSomething(false);
        break;
      case "Keys":
        await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive).whenComplete(() {
            appStatus.value = "Encryption keys Updated";
        });
        googleIsDoingSomething(false);
        break;
    }

  }
}
fileCheckCompleted = true;
}



  Future<void> restoreDBFiles() async {
    try {
      googleIsDoingSomething(true);
    //  readyButton.boolSink.add(true);
      appStatus.value = downloading_journal_files_message_string;
      await  googleDrive.syncBackupFiles(databaseName).whenComplete((){
        appStatus.value = "Your Journal is synced on device now";
        googleIsDoingSomething(false);
      });
    } on Exception catch (ex) {
      showMessage(ex.toString());
    }
  }

  Future<void> uploadDBFiles() async {
  setState(() {
    appStatus.value = "Beginning upload of updated journal";
  });
    try {
     // readyButton.boolSink.add(true);
      googleIsDoingSomething(true);
      setState(() {
        appStatus.value = "Checking for outdated journals";
      });
      bool multipleCopies = await googleDrive.checkForOutdatedFiles(databaseName);
      if(multipleCopies){
       await googleDrive.deleteOutdatedBackups(databaseName);
      } else{
      await googleDrive.deleteOutdatedBackups(databaseName).whenComplete(() {

        appStatus.value = "Uploading updated journal files";

      });
      }
      if(File("$dbLocation-wal").existsSync()) {
        googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
      }
      if(File("$dbLocation-shm").existsSync()) {
        googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
      }
   await   googleDrive.uploadFileToGoogleDrive(File(dbLocation)).whenComplete(() {
      setState(() {
        appStatus.value = "Finished uploading updated journal files";
      });
      googleIsDoingSomething(false);
   });
    } on Exception catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
      setState(() {
        appStatus.value = "Error uploading updated journal files";
      });
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
            padding: const EdgeInsets.all(20.0),
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
EncryptedSharedPreferences encryptedSharedPrefs = EncryptedSharedPreferences();
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
late String redirectOneDriveURL;
NetworkConnectivity networkConnectivityChecker = NetworkConnectivity.instance;

bool connected = false;
bool fileCheckCompleted= false;