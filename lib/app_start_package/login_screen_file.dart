// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'package:adhd_journal_flutter/drive_api_backup_general/google_drive_backup_class.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../drive_api_backup_general/CryptoUtils.dart';
import '../project_resources/project_colors.dart';
import 'onboarding_widget_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart'as enc;
import 'package:adhd_journal_flutter/drive_api_backup_general/preference_backup_class.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../main.dart';
import 'dart:io';

import 'splash_screendart.dart';

/// Required to open the application , simple login form to start

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
bool passwordEnabled = true;
 String dbPassword ='';
 String userPassword = '';
bool isPasswordChecked = false;
String greeting = '';
TextField loginField = TextField();
String dlDBPassword ='';
String dlUserPassword ="";
int dlColorSeed = 0;
String dlGreeting = '';
String dlPasswordHint = '';
bool dlPasswordEnabled = false;
String decipheredData ="";
bool isThisReturning = false;


///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen> {
  String loginPassword = '';
  String loginGreeting = '';
  var encryptedOrNot = false;
  late SharedPreferences sharedPrefs;
  late TextEditingController stuff;
  TextField loginField = TextField();
  Row greetingField = Row(children: [],);
  String hintText = '';
  String hintPrompt = '';
  ThemeSwap themeSwapper = ThemeSwap();
 ConnectivityResult? _connectivityResult;
 late StreamSubscription _connectivitySubscription;
 late  ElevatedButton driveButton;
 bool updated = false;
ValueNotifier appSynced = ValueNotifier(false);
  @override
  void initState() {
    super.initState();
getSyncState();
    loadStateStuff();
    if (passwordHint == '') {
      hintText = 'Enter secure password';
hintPrompt = 'The app now allows you to store a hint so it\'s easier to remember your password in case you forget. \r\n Set it to something memorable.\r\n This will be encrypted like your password so nobody can read your hint.'
    '\r\n You can enter this in settings.';
    } else {
      hintText ='Password Hint is : $passwordHint';
    }
    setState(() {
      driveButton = ElevatedButton(onPressed: () async{

      //  bool checkConnState = await Future.sync(() => _checkConnState());
    //    if(checkConnState){
        googleDrive.getHttpClient();
        updated = false;
        getSyncState();
        var checkDB = File(dbLocation);
        var checkKeys = File(path.join(keyLocation,"journ_privkey.pem"));
        var checkPrefs = File(docsLocation);
        googleDrive.client ??= await googleDrive.getHttpClientSilently();
        var checkDBOnline = await Future.sync(()=>googleDrive.checkForFile(dbName));
        var checkPrefsOnline = await Future.sync(() => googleDrive.checkForFile(prefsTransportName));
        var checkKeysOnline = await Future.sync(() => googleDrive.checkForFile("journ_privKey.pem"));

        if(checkDB.existsSync()&&checkPrefs.existsSync()&&checkKeys.existsSync()){
        if(checkDBOnline&&checkPrefsOnline&&checkKeysOnline){
          checkFileAge();}
        else{
          String dataForEncryption ='$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
          preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
          await Future.sync(() => uploadDBFiles());
        }
        } else {
          if(checkDBOnline&&checkPrefsOnline&&checkKeysOnline){
           await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
           await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
            await Future.sync(() => restoreDBFiles()).whenComplete(() => updateValues());
            //updateValues();
          }
          else{
            showMessage("You need to open up the journal for the first time!");
            preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);
          }
        }
   //     }
    //    else{
     //     showMessage("You must be connected to Wifi or Mobile data to sync your journal online!");
      //  }
        resetLoginFieldState();
        setState(() {
          Future.sync(() => getSyncStateStatus());
        });
      }, child: Row(children: const [Icon(Icons.add_to_drive),Text("Sign in to Drive")],));
      stuff = TextEditingController();
    });
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

  void loadStateStuff() async {
    prefs = await SharedPreferences.getInstance();

    greeting = prefs.getString("greeting") ?? '';
    loginGreeting = await Future.sync(() => getGreeting());
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
    passwordHint =await getPasswordHint();//encryptedSharedPrefs.getString('passwordHint');
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    isPasswordChecked = passwordEnabled;
    swapper?.themeColor=prefs.getInt('apptheme') ?? AppColors.mainAppColor.value;
if(userPassword != dbPassword){
  dbPassword = userPassword;

}
    // ignore: await_only_futures

// This code will get the Google Drive api token for usage in auto backup and sync
    setState(() {
      resetLoginFieldState();
    });
await Future.delayed(Duration(seconds: 3),() => googleDrive.googleSignIn?.signOut());
  }

  Future<String> getGreeting() async {
    //await Future.delayed(Duration(seconds: 2));
    greeting = prefs.getString('greeting') ?? '';
    String opener = 'Welcome ';
    String closer = '! Sign in with your password below.';

    return opener + greeting + closer;
  }

  Future<String> getPasswordHint() async{
    return encryptedSharedPrefs.getString("passwordHint");
  }

  Future<bool> getSyncStateStatus() async{
    return userActiveBackup;
}
// Code for value listenable and builder widget, could be a future?
  /// button widget will not change until prefs are done updating.


  Future<bool> getPasswordEnabledState() async {

    return prefs.getBool('passwordEnabled') ?? true;
  }

  void getSyncState(){
   while(updated == false){
     appSynced  = ValueNotifier(false);
     if(updated = true)
       break;
   }
   appSynced = ValueNotifier(true);

  }

  void refreshPrefs() async {
    prefs.reload();
    await Future.sync(()=>encryptedSharedPrefs.reload());
    await Future.delayed(Duration(seconds: 1),loadStateStuff);
    updated = true;
    getSyncState();
  }

  void resetLoginFieldState() {
    if (userActiveBackup) {
      if(isThisReturning== true){
        updated = false;
        getSyncState();
        checkFileAge();
      }
      if (!isDataSame) {
        setState(() {
          updated = false;
          getSyncState();
        updateValues();
        updated = true;
        getSyncState();});
      }

    }
    if(isDataSame){

      setState((){
      updated = true;
      getSyncState();});
    }
    setState(() {
      if (passwordHint == '' || passwordHint == ' ') {
        hintText = 'Enter secure password';
      } else {
        hintText = 'Password Hint is : $passwordHint';
      }
      greetingField = Row(children: [
        Expanded(
            child: Text(
              loginGreeting,
              style: TextStyle(
                fontSize: 20.0,
              ),
              textAlign: TextAlign.center,
            ))
      ]);


      if (passwordEnabled) {
        loginField = TextField(
          obscureText: true,
          controller: stuff,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password',
              hintText: hintText),
          onChanged: (text) {
            loginPassword = text;
            if (text.length == userPassword.length) {
              if (text == userPassword) {

                Navigator.pushNamed(context, '/success').then((value) =>
                { isThisReturning = true,
                  refreshPrefs(),
                  recordHolder.clear(),
                  stuff.clear(),
                });
              } else {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          "Invalid password",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: Text(
                            'You have entered the incorrect password. Please try again.'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Ok"))
                        ],
                      );
                    });
              }
            }
          },
          enabled: true,
        );
      } else {
        loginField = TextField(
          obscureText: true,
          controller: stuff,
          decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Password Disabled. Hit Login to continue',
              hintText: 'Password Disabled. Hit Login to continue'),
          onChanged: (text) {
            loginPassword = text;
          },
          enabled: false,
        );

      }
      if(updated==true){
        setState(() {
          getSyncState();
        });
      }
    });

  }


  /// Check the user's Google Drive for age of file or even if the file exists
  Future<void> checkFileAge() async {
    isThisReturning = false;
    File file = File(dbLocation);// DB

   // File txtFile = File(docsLocation); // Prefs
    File privKeyFile = File(path.join(keyLocation,"journ_privkey.pem"));
    try{
      bool fileCheckAge = false;
      fileCheckAge = await Future.sync(() =>  googleDrive.checkDBFileAge(dbName));


      String dataForEncryption ='$userPassword,$dbPassword,$passwordHint,${passwordEnabled.toString()},$greeting,$colorSeed';
var onlineKeys = await googleDrive.checkForFile('journ_privkey.pem');
// Keys first
if(!privKeyFile.existsSync() && onlineKeys) {
  await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
}
else if(!privKeyFile.existsSync() && !onlineKeys){
  preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);

}
else{
  preferenceBackupAndEncrypt.assignRSAKeys(googleDrive);
}
//MOST SCRUTINY FOR ALL THINGS

// Next Preferences
      bool fileCheckCSV = await googleDrive.checkForFile('journalStuff.txt');
      bool txtFileCheckAge = false;
      //Check for file
if(fileCheckCSV) { // If file exists on Google Drive execute
  txtFileCheckAge = await googleDrive.checkCSVFileAge('journalStuff.txt');
  if (txtFileCheckAge) { // if file is older in the cloud
    preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
  }
  else {
   await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
   if(dataForEncryption == decipheredData){
     getSyncState();
   }else{
     isDataSame=false;
   }
  }
}  else{ //otherwise
    File checkPrefsTxt = File(docsLocation);
    if(checkPrefsTxt.existsSync()){
      checkPrefsTxt.deleteSync();
    } else{
      await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
      if(dataForEncryption==decipheredData){
        isDataSame = true;
      } else{
        isDataSame = false;
      }
    }
  }
bool isDBOnline = await googleDrive.checkForFile(dbName);

//Last DB
    if (!fileCheckAge || !file.existsSync()) {
      if(isDBOnline){
      await restoreDBFiles();
      } else{
        throw Exception("File not on Google Drive, you'll need to open app first");
      }
    } else {
      await uploadDBFiles();

    }
      if(!isDataSame){
        updateValues();

      }
    } on Exception catch (ex){
      showMessage(ex.toString());
      await(restoreDBFiles());
      preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
      await preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
      if(!isDataSame){
        updateValues();

      }

    }

  }
//Experimental
  Future<void> uploadDBFiles() async {
    googleDrive.deleteOutdatedBackups("activitylogger_db.db");
    googleDrive.uploadFileToGoogleDrive(File(dbLocation));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
    showMessage('Your journal is now uploaded!');
  }

  //Experimental
  Future<void> restoreDBFiles() async {
    try {
       await Future.sync(()=>googleDrive.syncBackupFiles(dbName));
      var getFileTime = File(dbLocation);
      var time = getFileTime.lastModifiedSync();
     showMessage('Your journal is synced as of ${time.toLocal()}');
    } on Exception catch (ex) {
      showMessage('You need to open up the journal once to back it up.');
    }
  }

  void showMessage(String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message)
        ));
  }
/// Testing after 15 successful tries of simply moving between devices
  void updateValues() async{
    showMessage("Updating preferences");
   setState((){
    updated = false;
    getSyncState();});
    if(decipheredData ==''){
   File prefsFile = File(docsLocation);
   if(prefsFile.existsSync()){
     decipheredData = CryptoUtils.rsaDecrypt(prefsFile.readAsStringSync(encoding: Encoding.getByName("utf-8")!),preferenceBackupAndEncrypt.privKey!);
   }
    else{
      preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
   }
    }
    var newValues = decipheredData.split(',');
    dlUserPassword = newValues[0];
    dlDBPassword = newValues[1];
    dlPasswordHint = newValues[2];
    dlPasswordEnabled = newValues[3] == "true" ? true : false;
    dlGreeting = newValues[4];
    dlColorSeed = int.parse(newValues[5]);
   if(userPassword !=dlUserPassword || userPassword != dbPassword) {
     userPassword = dlUserPassword;
     var test = await encryptedSharedPrefs.getString('dbPassword');
     if (test != dbPassword) {
       print(test);
     }
     if (dbPassword != userPassword) {
       dbPassword = userPassword;
     }
     await encryptedSharedPrefs.setString('loginPassword', userPassword);
   }
   if(passwordEnabled != dlPasswordEnabled){
     passwordEnabled = dlPasswordEnabled;
     prefs.setBool('passwordEnabled', passwordEnabled);
     getPasswordEnabledState();
   }
   if(passwordHint != dlPasswordHint){
     passwordHint = dlPasswordHint;
     await Future.sync(() =>encryptedSharedPrefs.setString('passwordHint', passwordHint));
   }
   if(greeting != dlGreeting){
     greeting = dlGreeting;
     prefs.setString('greeting', greeting);
   }
   if(colorSeed!=dlColorSeed){
     colorSeed = dlColorSeed;
prefs.setInt('apptheme', colorSeed);
setState((){
checkColors(colorSeed);});
   }
   print("updated Values in array");
   isDataSame = true;
   decipheredData = '';
   refreshPrefs();



  }
  void checkColors(int value){
setState(() {
  swapper?.themeColor = value;
  swapper?.notifyListeners();
});



  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, swapper, child) {

    return Scaffold(
      appBar: AppBar(
        title: Text("ADHD Journal"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: greetingField,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: loginField,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(),
            ),
            SizedBox(
              height: 50,
              width: 250,
              child:
              ValueListenableBuilder(valueListenable: appSynced, builder: (BuildContext context,value,Widget? child){
                if(value ==true){
    return FutureBuilder(
    future: getPasswordEnabledState(),
    builder: (BuildContext context,
    AsyncSnapshot<bool> snapshot,) {
    if (snapshot.hasError) {
    return Text(
    'Error returning password  information');
    } else if (snapshot.hasData) {
    return ElevatedButton(
    onPressed: () {
    callingCard = true;
    if (loginPassword == userPassword &&
    passwordEnabled) {
    loginPassword = '';
    recordsBloc = RecordsBloc();

    Navigator.pushNamed(context, '/success')
        .then((value) => { isThisReturning = true,

    stuff.clear(),
    recordHolder.clear(),
    refreshPrefs(),
    });
    } else if (!passwordEnabled) {

    recordsBloc = RecordsBloc();
    loginPassword = '';
    stuff.clear();
    Navigator.pushNamed(context, '/success').then(
    (value) => {isThisReturning = true,
    refreshPrefs(),
    recordHolder.clear(),
    });
    }
    },
    child: Text(
    'Login',
    style: TextStyle(fontSize: 25),
    ),
    );
    } else if (snapshot.connectionState ==
    ConnectionState.waiting) {
    return ElevatedButton(
    onPressed: () {
    if (loginPassword == userPassword) {
    Navigator.pushNamed(context, '/success').then(
    (value) => {
    isThisReturning = true,
    recordHolder.clear(),
    refreshPrefs(),
    recordsBloc.dispose(),
    });
    stuff.clear();
    }
    },
    child: Text(
    'Login',
    style: TextStyle(color: Colors.white, fontSize: 25),
    ),
    );
    } else {
    return Text('Waiting for password info');
    }
    });}
                else{
                  return Text("Updating Values, please wait");
              }}),),
          SizedBox(height: 130,),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(child:  FutureBuilder( future: getSyncStateStatus(),
                  builder: (BuildContext context, AsyncSnapshot<bool> snapshot,){
                if(snapshot.hasError){
                  return Text("Error");
                }
                else if(snapshot.hasData){
                  if(snapshot.data! == true){
                    return Text("");
                  }
                  else{
                    return driveButton;
                  }
                }
                else {
                  return Text("Waiting");
                }
              }),),
            ),
            SizedBox(
              height: 50, child:  ElevatedButton(
              onPressed: () {
               try{
                  googleSignIn();
                 checkFileAge();
                 if(googleDrive.googleSignIn?.isSignedIn()==true){
                 googleDrive.googleSignIn?.signOut();}
               } on Exception catch(ex){
                 restoreDBFiles();
                 updateValues();
               }
              },
              child: Text(
                'Update Files',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
            ),
            ),
          ],
        ),
      ),
    );
        }
        );
  }

  void googleSignIn() async{
    googleDrive.client = await googleDrive.getHttpClientSilently();
  }

}

String driveStoreDirectory = "Journals";
PreferenceBackupAndEncrypt preferenceBackupAndEncrypt = PreferenceBackupAndEncrypt();

