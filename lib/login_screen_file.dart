// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'recordsdatabase_handler.dart';
import 'main.dart';




String greeting = '';
TextField loginField = TextField();
late SharedPreferences prefs;
/// Required to open the application , simple login form to start
class LoginScreen extends StatefulWidget{
const LoginScreen({Key? key,}) : super(key: key);

@override
  State<LoginScreen> createState() => _LoginScreenState();

}

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen> {

  late String? userPassword;
  String loginPassword = '';

  late SharedPreferences sharedPrefs;
  late TextEditingController stuff;

  @override void initState() {
    super.initState();
    loadStateStuff();


    stuff = TextEditingController();
  }

  void loadStateStuff() async {
    prefs = await SharedPreferences.getInstance();
    sharedPrefs = prefs;
    greeting = sharedPrefs.getString('greeting') ?? '';
    userPassword = '';
    userPassword = sharedPrefs.getString('loginPassword') ?? '1234';
    if (userPassword == '') {
      userPassword = '1234';
      sharedPrefs.setString('loginPassword', userPassword!);
    }
  }

  Future<String> getGreeting() async {
    await Future.delayed(Duration(seconds: 3));
    String opener = 'Welcome ';
    String closer = '! Sign in with your password below.';
    greeting = sharedPrefs.getString('greeting') ?? '';
    return opener + greeting + closer;
  }

  Future<bool> getPassword() async {
    await Future.delayed(Duration(seconds: 2));
    return sharedPrefs.getBool('passwordEnabled') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body:
      SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: FutureBuilder(future: getGreeting(),
                  builder: (BuildContext context,
                      AsyncSnapshot<String> snapshot,) {
                    print(snapshot.connectionState);
                    if (snapshot.hasError) {
                      return Text('Error loading greeting');
                    }
                    else
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Welcome! Sign in below to continue.',
                          style: TextStyle(fontSize: 20.0));
                    }
                    else if (snapshot.hasData) {
                      return Row(children: [Expanded(child: Text(
                        snapshot.data!, style: TextStyle(fontSize: 20.0,),
                        textAlign: TextAlign.center,))
                      ]);
                    }
                    else {
                      return const Text("Welcome! Sign in below to continue.",
                          style: TextStyle(fontSize: 20.0));
                    }
                  },
                )
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: /*loginField*/
              FutureBuilder(future: getPassword(),
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> snapshot,) {
                    print(snapshot.connectionState);
                    if (snapshot.hasError) {
                      return Text(
                          'Error returning password enabled information');
                    }
                    else if (snapshot.hasData) {
                      if (prefs.getBool('passwordEnabled')==true) {
                        return TextField(
                          obscureText: true,
                          controller: stuff,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              hintText: 'Enter secure password'),
                          onChanged: (text) {
                            loginPassword = text;
                          },
                          enabled: true,
                        );
                      }
                      else {
                        return TextField(
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
                    }
                    else
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text('Waiting for Password Info');
                    }
                    else {
                      return Text('Waiting for password info');
                    }
                  }
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: Center(

              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: FutureBuilder(future: getPassword(),
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> snapshot,) {
                    print(snapshot.connectionState);
                    if (snapshot.hasError) {
                      return Text(
                          'Error returning password enabled information');
                    }
                    else if (snapshot.hasData) {
                      return ElevatedButton(
                        onPressed: () {
                          if (sharedPrefs.getBool('passwordEnabled') == false) {
                            print('Password Disabled');
                            print('navigating to the home screen');
                            Navigator.pushNamed(context, '/success');
                          }
                          else if (loginPassword == userPassword) {
                            print('Password Enabled');
                            print('navigating to the home screen');
                            Navigator.pushNamed(context, '/success');
                            stuff.clear();
                          }
                        },
                        child: Text('Login', style: TextStyle(color: Colors
                            .white, fontSize: 25),),);
                    }
                    else
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ElevatedButton(
                        onPressed: () {
                          if (loginPassword == userPassword) {
                            Navigator.pushNamed(context, '/success');
                            stuff.clear();
                          }
                        },
                        child: Text('Login', style: TextStyle(color: Colors
                            .white, fontSize: 25),),);
                    }
                    else {
                      return Text('Waiting for password info');
                    }
                  }

              ),),
            SizedBox(
              height: 130,
            ),
          ],
        ),
      ),
    );
  }
}