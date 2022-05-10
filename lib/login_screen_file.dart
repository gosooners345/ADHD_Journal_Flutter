// ignore_for_file: prefer_const_constructors

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'main.dart';
import 'recordsdatabase_handler.dart';
import 'splash_screendart.dart';

String greeting = '';
TextField loginField = TextField();
late Database recdatabase;

/// Required to open the application , simple login form to start
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

late RecordsDB recordsDataBase;
late String dbPassword;
late String userPassword;

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen> {
  String loginPassword = '';
  String loginGreeting = '';
  bool passwordEnabled = true;
  late SharedPreferences sharedPrefs;
  late TextEditingController stuff;
  late Widget loginField;
  late Widget greetingField;

  @override
  void initState() {
    super.initState();
    encryptedSharedPrefs = EncryptedSharedPreferences();
    loadStateStuff();
    setState(() {
      stuff = TextEditingController();

      resetLoginFieldState();
    });
  }

  void loadDB() async {
    try {
      recordsDataBase = RecordsDB();
      recdatabase = await recordsDataBase.database;
      if (recdatabase.isOpen) {
        print("DB open");
      }
      recordHolder = await recordsDataBase.getRecords();
    } on Exception catch (ex) {
      print(ex);
    }
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
    passwordEnabled = prefs.getBool('passwordEnabled') ?? true;
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
  }

  void resetLoginFieldState() {
    setState(() {
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
              hintText: 'Enter secure password'),
          onChanged: (text) {
            loginPassword = text;
            if (text.length == userPassword.length) {
              if (text == userPassword) {
                loadDB();
                recordsDataBase.getDBLoaded(false);
                Navigator.pushNamed(context, '/success').then((value) => {
                      refreshPrefs(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login Page"),
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
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: loginField,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(
//child: loginField
                  ),
            ),
            Container(
              height: 50,
              width: 250,
              child: FutureBuilder(
                  future: getPassword(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<bool> snapshot,
                  ) {
                    if (snapshot.hasError) {
                      return Text(
                          'Error returning password enabled information');
                    } else if (snapshot.hasData) {
                      return ElevatedButton(
                        onPressed: () {
                          refreshPrefs();

                          if (loginPassword == userPassword &&
                              passwordEnabled) {
                            stuff.clear();
                            loginPassword = '';
                            loadDB();
                            Navigator.pushNamed(context, '/success')
                                .then((value) => {
                                      refreshPrefs(),
                                      resetLoginFieldState(),
                                    });
                          } else if (!passwordEnabled) {
                            loginPassword = '';
                            stuff.clear();
                            loadDB();
                            Navigator.pushNamed(context, '/success').then(
                                (value) =>
                                    {refreshPrefs(), resetLoginFieldState()});
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
                            loadDB();
                            Navigator.pushNamed(context, '/success').then(
                                (value) =>
                                    {refreshPrefs(), resetLoginFieldState()});
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
          ],
        ),
      ),
    );
  }
}
