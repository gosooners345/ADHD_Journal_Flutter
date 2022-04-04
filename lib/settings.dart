import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';


String dbPasswordKey = 'dbPassword';
String loginPasswordKey = 'userPassword';
String passwordValue = '';
String dbPasswordValue = '';


class SettingsWidget extends StatefulWidget{
  const SettingsWidget({Key? key}) : super(key: key);




  @override
  State<StatefulWidget> createState() {
   return _SettingsWidgetState();
  }



}

class _SettingsWidgetState extends State<SettingsWidget>{
  @override
  Widget build(BuildContext context) {

    throw UnimplementedError();
  }

}
