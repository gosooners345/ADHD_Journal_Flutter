// ignore_for_file: prefer_const_constructors

import 'package:adhd_journal_flutter/settings.dart';
import 'package:flutter/material.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'recordsdatabase_handler.dart';
import 'main.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';



/// Required to open the application , simple login form to start
class LoginScreen extends StatefulWidget{
const LoginScreen({Key? key}) : super(key: key);

@override
  State<LoginScreen> createState() => _LoginScreenState();

}

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen>{

  late TextField passwordTxtField;
  late TextEditingController passwordController;

  String userPassword = '';
  String dbPassword = '';
  String password = '';
  bool passwordSubmission = false;
  final EncryptedSharedPreferences encryptedSharedPreferences =
      EncryptedSharedPreferences();
@override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    passwordTxtField = TextField(controller: passwordController, onChanged: (text) {
      setState(() {
        userPassword = text;
      });
    },
      onSubmitted: (value){
      userPassword = value;
      },
      obscureText: true,
      decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Password',
          hintText: 'Enter secure password'),
    );
_loadPassword();
  }

  void _loadPassword() async{
  encryptedSharedPreferences.getString(loginPasswordKey ?? '1234').then((String value) {
    setState(() {
      password = value;
    });
  } );
  if(loginPasswordKey == '') {
      password = '1234';
    encryptedSharedPreferences.setString(loginPasswordKey, password);
    encryptedSharedPreferences.setString(dbPasswordKey, password);
    }
  encryptedSharedPreferences.getString(dbPasswordKey ?? '1234').then((String value) {
    setState(() {
      dbPassword = value;
    });
  } );


  }
  
  void _savePassword() async{
  encryptedSharedPreferences.setString(loginPasswordKey,userPassword );

  }

  void _checkPasswordValue(String userPassword) async{
  if(userPassword == password) {
    passwordSubmission = true;
  } else {
    passwordSubmission=false;
  }
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
              child: ElevatedButton(
                onPressed: () {
                  _checkPasswordValue(userPassword);

                  Navigator.pushNamed(context, '/success');                },
                child: Text(
                  'Login',
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
