// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:adhd_journal_flutter/drive_api_backup_general/google_drive_backup_class.dart';
import 'package:adhd_journal_flutter/records_stream_package/records_bloc_class.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../project_resources/project_colors.dart';
import 'onboarding_widget_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart'as enc;
import 'package:adhd_journal_flutter/drive_api_backup_general/preference_backup_class.dart';
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
late String dbPassword;
late String userPassword;
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


GoogleDrive googleDrive = GoogleDrive();
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

 late  ElevatedButton driveButton;

  @override
  void initState() {
    super.initState();

    loadStateStuff();
    if (passwordHint == '') {
      hintText = 'Enter secure password';
hintPrompt = 'The app now allows you to store a hint so it\'s easier to remember your password in case you forget. \r\n Set it to something memorable.\r\n This will be encrypted like your password so nobody can read your hint.'
    '\r\n You can enter this in settings.';
    } else {
      hintText ='Password Hint is : $passwordHint';
    }
    setState(() {
      driveButton = ElevatedButton(onPressed: (){
        googleDrive.getHttpClient();
        checkFileAge();
        resetLoginFieldState();
        setState(() {
          getSyncStateStatus();
        });
      }, child: Row(children: const [Icon(Icons.add_to_drive),Text("Sign in to Drive")],));
      stuff = TextEditingController();
    });

  }



  void loadStateStuff() async {
    prefs = await SharedPreferences.getInstance();
    sharedPrefs = prefs;
    greeting = prefs.getString("greeting") ?? '';
    loginGreeting = "Welcome $greeting !"
        " Please sign in below to get started!";
    userPassword = '';
    userPassword = await encryptedSharedPrefs.getString('loginPassword');
    dbPassword = await encryptedSharedPrefs.getString('dbPassword');
    passwordHint =await encryptedSharedPrefs.getString('passwordHint');
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    isPasswordChecked = passwordEnabled;
    userActiveBackup = prefs.getBool('testBackup') ?? false;
    if(userActiveBackup){
      try{
      googleDrive.getHttpClientSilently();}
          on Exception catch (ex){
        googleDrive.getHttpClientSilently();
          }
    }
    // ignore: await_only_futures
    apiKey = await Future.delayed(Duration(seconds: 1),(){encryptedSharedPrefs.getString('apiStorage');}).toString();
    if(kDebugMode) {
      if (apiKey!.isNotEmpty){
      print(apiKey);
    }
    }
// This code will get the Google Drive api token for usage in auto backup and sync
    setState(() {
      resetLoginFieldState();
    });
  }

  Future<String> getGreeting() async {
    await Future.delayed(Duration(seconds: 2));
    String opener = 'Welcome ';
    String closer = '! Sign in with your password below.';
    greeting = prefs.getString('greeting') ?? '';
    return opener + greeting + closer;
  }

  Future<bool> getSyncStateStatus() async{
   await Future.delayed(Duration(seconds: 1));
    return userActiveBackup;
}

  Future<bool> getPassword() async {
    await Future.delayed(Duration(seconds: 0));
    return prefs.getBool('passwordEnabled') ?? true;
  }

  void refreshPrefs() async {
    prefs.reload();
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    greeting = prefs.getString("greeting") ?? '';
    loginGreeting = "Welcome $greeting! Please sign in below to get started!";
    userActiveBackup = prefs.getBool('testBackup')?? false;
    getSyncStateStatus();
    resetLoginFieldState();
  }

  void resetLoginFieldState() {
    if (userActiveBackup) {
      checkFileAge();
      //  encryptedSharedPrefs.setString('apiStorage', apiKey);
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
                {
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
    });
  }


  /// Check the user's Google Drive for age of file or even if the file exists
  Future<void> checkFileAge() async {
    File file = File(dbLocation);// DB
    File txtFile = File(docsLocation); // Prefs
    File privKeyFile = File(path.join(keyLocation,"journ_privkey.pem"));
    try{
      bool fileCheckAge = false;
try{
await Future.delayed(Duration(seconds: 3),() async {
  fileCheckAge = await googleDrive.checkDBFileAge("activitylogger_db.db-wal");
});
}
on Exception catch (ex){
      fileCheckAge = await googleDrive.checkDBFileAge("activitylogger_db.db")? true: false;
}
      String dataForEncryption = userPassword+','+dbPassword+','+passwordHint+','+passwordEnabled.toString()+","+greeting+','+colorSeed.toString();
var onlineKeys = await googleDrive.checkForCSVFile('journ_privkey.pem');
// Keys first
if(!privKeyFile.existsSync() && onlineKeys) {
  await preferenceBackupAndEncrypt.downloadRSAKeys(googleDrive);
}
else if(!privKeyFile.existsSync() && !onlineKeys){
  preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(googleDrive);

}
// Next Preferences
      bool fileCheckCSV = await googleDrive.checkForCSVFile('journalStuff.txt');
      bool txtFileCheckAge = false;
      //Check for file
if(fileCheckCSV) {
  txtFileCheckAge = await googleDrive.checkCSVFileAge('journalStuff.txt');
  if(txtFileCheckAge) { // if file is older in the cloud
    if (!txtFile.existsSync()) {
      preferenceBackupAndEncrypt.encryptData(dataForEncryption, googleDrive);
    }
  }
  else{
    preferenceBackupAndEncrypt.downloadPrefsCSVFile(googleDrive);
    showMessage(decipheredData);
  }
}
//Last DB
    if (!fileCheckAge || !file.existsSync()) {
      print(false);
      await restoreDBFiles();
    } else {
      print(true);
    await   uploadDBFiles();
    }
    } on Exception catch (ex){
      restoreDBFiles();
      print(ex.toString());
    }

  }
//Experimental
  Future<void> uploadDBFiles() async {
    googleDrive.getHttpClientSilently();
    if (kDebugMode) {
      print("Uploading Now");
    }
    googleDrive.deleteOutdatedBackups("activitylogger_db.db");
    googleDrive.uploadFileToGoogleDrive(File(dbLocation));

    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Your journal is now uploaded!'),

        ));
  }

  //Experimental
  Future<void> restoreDBFiles() async {
    googleDrive.getHttpClientSilently();
    try {
      googleDrive.syncBackupFiles("activitylogger_db.db");
      var getFileTime = File(dbLocation);
      var time = getFileTime.lastModifiedSync();
// Show Snack Bar displaying the last time action was
     showMessage('Your journal is synced as of ${time.toUtc()}');
      print("successful");
    } on Exception catch (ex) {
      print(ex.toString());
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
  void checkValuesAndAssign() async{
    var newValues = decipheredData.split(',');
    //String values = userPassword+','+dbPassword+','+passwordHint+','+passwordEnabled.toString()+","+greeting+','+colorSeed.toString();
    dlUserPassword = newValues[0];
   // dlDBPassword = newValues[1];
    dlPasswordHint = newValues[2];
    dlPasswordEnabled = newValues[3] == "true" ? true : false;
    dlGreeting = newValues[4];
    dlColorSeed = int.parse(newValues[5]);
   if(userPassword !=dlUserPassword){
     userPassword = dlUserPassword;
     recordsBloc = RecordsBloc();
     recordsBloc.changeDBPasswords();
     recordsBloc.dispose();
    await encryptedSharedPrefs.setString('loginPassword', userPassword);
   }
   if(passwordEnabled != dlPasswordEnabled){
     passwordEnabled = dlPasswordEnabled;
     prefs.setBool('passwordEnabled', passwordEnabled);
     getPassword();
   }
   if(passwordHint != dlPasswordHint){
     passwordHint = dlPasswordHint;
     await encryptedSharedPrefs.setString('passwordHint', passwordHint);
   }
   if(greeting != dlGreeting){
     greeting = dlGreeting;
     prefs.setString('greeting', greeting);
   }
   if(colorSeed!=dlColorSeed){
     colorSeed = dlColorSeed;
     ThemeSwap themeSwapper = ThemeSwap();
     setState(() {
       themeSwapper.themeColor=colorSeed;
     });
   }
   print("updated Values in array");
   loadStateStuff();


  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
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
              child: FutureBuilder(
                  future: getPassword(),
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
                            Navigator.pushNamed(context, '/success')
                                .then((value) => {
                              stuff.clear(),
                              recordHolder.clear(),
                              refreshPrefs(),
                            });
                          } else if (!passwordEnabled) {
                            loginPassword = '';
                            stuff.clear();
                            Navigator.pushNamed(context, '/success').then(
                                    (value) => {
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
                  }),
            ),
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
              height: 130, child:  ElevatedButton(
              onPressed: () {
                preferenceBackupAndEncrypt.replaceRsaKeys(googleDrive);
              },
              child: Text(
                'Reset RSA Keys',
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
}

String driveStoreDirectory = "Journals";
PreferenceBackupAndEncrypt preferenceBackupAndEncrypt = PreferenceBackupAndEncrypt();
String ivTest ='';

