import 'dart:async';
import 'package:adhd_journal_flutter/onboarding_widget_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>{

  @override
  Widget build(BuildContext context){
    return initScreen(context);
  }

  @override
  void initState(){
    super.initState();
    loadPreferences();
startTimer();
  }
  void loadPreferences() async{
    prefs = await SharedPreferences.getInstance();
  }
  
  
   startTimer() async{
    var duration = const Duration(seconds: 5);
    return Timer(duration,route);
  }
  //First time users go to the onboarding section to get a tutorial, returning users don't
  route(){
    var firstVisit = prefs.getBool('firstVisit') ?? true;
    if(firstVisit){
      Navigator.pushReplacementNamed(context,'/onboarding');
    }
    else{
Navigator.pushReplacementNamed(context, '/login');
    }
    
  }
  

  initScreen(BuildContext context){
    return Scaffold(body:  Column(
    children: <Widget>[const SizedBox(height: 35,),
      Container(
    child: Image.asset('images/app_icon_demo.png'),
    ),const Padding(padding: EdgeInsets.only(top:20.0),child:
    Text('Welcome to ADHD Journal! Loading up your journal  now...'),),
    ],
    ),
    );
  }







}
late SharedPreferences prefs;
