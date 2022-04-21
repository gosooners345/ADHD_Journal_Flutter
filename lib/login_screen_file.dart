// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'project_colors.dart';
import 'project_strings_file.dart';
import 'recordsdatabase_handler.dart';
import 'main.dart';



/// Required to open the application , simple login form to start
class LoginScreen extends StatefulWidget{
const LoginScreen({Key? key}) : super(key: key);

@override
  State<LoginScreen> createState() => _LoginScreenState();

}

///Handles the states of the application.
class _LoginScreenState extends State<LoginScreen>{
 
  late String? userPassword;
  String loginPassword = '';
  late SharedPreferences sharedPrefs;
  late TextEditingController stuff;
  
  @override void initState()  {
    super.initState();
    stuff = TextEditingController();
   loadStateStuff();


  }
 
 void loadStateStuff() async{
   sharedPrefs = await SharedPreferences.getInstance();
   userPassword = '';
   userPassword = sharedPrefs.getString('loginPassword') ?? '1234';
   if(userPassword =='')
   {
     userPassword = '1234';
     sharedPrefs.setString('loginPassword', userPassword!);
     sharedPrefs.commit();
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
                obscureText: true,
                controller: stuff,
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter secure password'),
                onChanged: (text){
                  loginPassword = text;
                },
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


                    if (loginPassword == userPassword) {
                      Navigator.pushNamed(context, '/success');
                      stuff.clear();
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
                onPressed: () {
                sharedPrefs.setString('loginPassword', loginPassword);
                userPassword=loginPassword;
                
                              },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
