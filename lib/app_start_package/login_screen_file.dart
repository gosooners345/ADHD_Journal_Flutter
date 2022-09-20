// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:adhd_journal_flutter/drive_api_backup_general/google_drive_backup_class.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import '../drive_api_backup_general/security_storage.dart';
import '../project_resources/project_colors.dart';
import 'onboarding_widget_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

late String dbPassword;
late String userPassword;
bool isPasswordChecked = false;
String greeting = '';
TextField loginField = TextField();

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen> {
  String loginPassword = '';
  String loginGreeting = '';
  bool passwordEnabled = true;
  late SharedPreferences sharedPrefs;
  late TextEditingController stuff;
  late Widget loginField;
  late Widget greetingField;
  String hintText = '';
  String hintPrompt = '';
GoogleDrive googleDrive = GoogleDrive();

  @override
  void initState() {
    super.initState();
    if (passwordHint == '') {
      hintText = 'Enter secure password';
hintPrompt = 'The app now allows you to store a hint so it\'s easier to remember your password in case you forget. \r\n Set it to something memorable.\r\n This will be encrypted like your password so nobody can read your hint.'
    '\r\n You can enter this in settings.';

    } else {
      hintText ='Password Hint is : $passwordHint';
    }
    loadStateStuff();
    setState(() {
      stuff = TextEditingController();
      resetLoginFieldState();
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
// This code seem

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

  Future<bool> getPassword() async {
    await Future.delayed(Duration(seconds: 0));
    return prefs.getBool('passwordEnabled') ?? true;
  }

  void refreshPrefs() async {
    prefs.reload();
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
    greeting = prefs.getString("greeting") ?? '';
    loginGreeting = "Welcome $greeting! Please sign in below to get started!";
    resetLoginFieldState();
  }

  void resetLoginFieldState() {
    setState(() {
      if (passwordHint == '' || passwordHint == ' ') {
        hintText = 'Enter secure password';
      } else {
        hintText ='Password Hint is : $passwordHint';
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
                  recordHolder.clear(),
                  stuff.clear(),
                  resetLoginFieldState(),
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

  Future<void> googleAuthenticationMethod() async{

    bool dbexists = await databaseExists(dbLocation);
  googleDrive.getHttpClient();
userActiveBackup = true;
prefs.setBool("drivebackup", userActiveBackup);
uploadDBFiles();


  }
//Experimental
  Future<void> uploadDBFiles() async {
    googleDrive.deleteOutdatedBackups("activitylogger_db.db");
    googleDrive.uploadFileToGoogleDrive(File(dbLocation));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-wal"));
    googleDrive.uploadFileToGoogleDrive(File("$dbLocation-shm"));
    print("Backup saved");
  }
  //Experimental
  Future<void> restoreDBFiles() async {
    googleDrive.getHttpClient();
googleDrive.downloadDatabaseBackups("activitylogger_db.db");
    print("successful");
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
    return Scaffold(
      //backgroundColor: Colors.white,
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
                          'Error returning password enabled information');
                    } else if (snapshot.hasData) {
                      return ElevatedButton(
                        onPressed: () {
                          callingCard = true;
                          setState(() {
                            resetLoginFieldState();
                          });
                          if (loginPassword == userPassword &&
                              passwordEnabled) {
                            if(userActiveBackup){
                              uploadDBFiles();
                            }
                            loginPassword = '';
                            Navigator.pushNamed(context, '/success')
                                .then((value) => {
                              stuff.clear(),
                              recordHolder.clear(),
                              refreshPrefs(),
                              setState(() {
                                resetLoginFieldState();
                              }),
                            });
                          } else if (!passwordEnabled) {

                            refreshPrefs();
                            loginPassword = '';
                            stuff.clear();
                            if(userActiveBackup){
                            uploadDBFiles();
                            }
                            Navigator.pushNamed(context, '/success').then(
                                    (value) => {
                                  recordHolder.clear(),
                                  refreshPrefs(),
                                  setState(() {
                                    resetLoginFieldState();
                                  }),
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
                          resetLoginFieldState();
                          if (loginPassword == userPassword) {
                            print(dbLocation);
                            if(userActiveBackup){
                              uploadDBFiles();
                            }
                            Navigator.pushNamed(context, '/success').then(
                                    (value) => {
                                  recordHolder.clear(),
                                  refreshPrefs(),
                                  resetLoginFieldState(),
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
            SizedBox(
              height: 130,
            ),

            IconButton(onPressed: (){
              googleAuthenticationMethod();
            }, icon: Icon(Icons.add_to_drive_outlined)),
            IconButton(onPressed: (){
              restoreDBFiles();
            }, icon: Icon(Icons.download))
          ],
        ),
      ),
    );
        }
        );
  }
}

String driveStoreDirectory = "Journals";



