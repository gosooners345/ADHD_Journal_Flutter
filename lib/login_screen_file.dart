// ignore_for_file: prefer_const_constructors

import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'recordsdatabase_handler.dart';
import 'main.dart';


late String password;
/// Required to open the application , simple login form to start
class LoginScreen extends StatefulWidget{
const LoginScreen({Key? key}) : super(key: key);

@override
  State<LoginScreen> createState() => _LoginScreenState();

}

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen>{


@override
  void initState() {
  super.initState();
  password = "";
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
              child: Text('Welcome! Sign in with your password below.'),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              //padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
              onChanged: (value){
                  password = value;
              },),
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
              child: ElevatedButton(
                onPressed: () async{
                  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
                  if(await prefs.getString('loginPassword') == '' )
                    {
                      prefs.setString('loginPassword',password );
                      prefs.setString('dbPassword', password);
                    }
                  if(password == await prefs.getString('loginPassword')){
                    Navigator.pushNamed(context, '/success');
                  }
                  },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),

            ),
            SizedBox(
              height: 130,
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: ElevatedButton(
                onPressed: () async{
                  EncryptedSharedPreferences prefs = EncryptedSharedPreferences();
               await     prefs.setString('loginPassword',password );
            //  await      prefs.setString('dbPassword', password);
                },
                child: Text(
                  'Save Password',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),

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
