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
    return Scaffold(body: Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(image: DecorationImage(image: const AssetImage('images/testphoto.png'),fit: BoxFit.cover),
    ),child: Column(
    children: <Widget>[
      Container(
    child: Image.asset('images/testphoto.png'),
    ),Padding(padding: EdgeInsets.only(top:20.0),),
    Text('Welcome to ADHD Journal!'),
    Padding(padding: EdgeInsets.only(top:20.0)),
    SizedBox(height: 20,),
    Text('Loading your journal up now...'),
    ],
    ),
    ),);
  }







}
late SharedPreferences prefs;
