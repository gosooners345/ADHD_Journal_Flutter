import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'splash_screendart.dart';
import 'login_screen_file.dart';
import 'recordsdatabase_handler.dart';
import 'login_screen_file.dart';




class SettingsPage extends StatefulWidget{
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPage();

}


class _SettingsPage extends State<SettingsPage>{
  static const platform = MethodChannel('com.activitylogger.release1/ADHDJournal');

  //Parameter setting stuff
  bool isChecked=false;
  //Preference Values
  String passwordValue = '';
  String greetingValue = '';
  Text passwordLabelWidget = Text('');
  bool passwordEnabled = false;
  late SwitchListTile passwordEnabledTile;
  //Visual changes based on parameter values
  String passwordLabelText = 'Password Enabled';
  // ignore: prefer_const_constructors
  late Icon lockIcon;
  // Convenience Widget for spacing and alignment
  SizedBox spacer = const SizedBox(height: 16,width: 8);
  //Text Controllers
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController greetingController = TextEditingController();



  @override
  void initState() {
    super.initState();
// Parameter Value setting
    greetingValue = prefs.getString('greeting') ?? '';
    passwordValue = prefs.getString('loginPassword') ?? '';
    isChecked = prefs.getBool('passwordEnabled')?? true;

    setState(() {
      greetingController = TextEditingController(text : greetingValue);
      passwordController = TextEditingController(text: passwordValue);
      if(isChecked){
      lockIcon = Icon(Icons.lock);
      passwordLabelText = "Password Enabled";
      passwordLabelWidget = Text(passwordLabelText);
      }
      else {
        lockIcon = Icon(Icons.lock_open);
        passwordLabelText = "Password Disabled";
        passwordLabelWidget = Text(passwordLabelText);

      }

    });

   // loadPrefs();
   //loadParameters();

  }


  ///Save string values into the preferences
  void saveSettings(String value, String key) async{
    prefs.setString(key, value);
  }

  void saveSettings2(bool value, String key) async{
    prefs.setBool(key, value);
    prefs.commit();
  }

  /// The display for the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Settings'),
      leading: IconButton(onPressed: (){
        prefs.setBool('passwordEnabled', isChecked);
        saveSettings(passwordValue, 'loginPassword');
        saveSettings(greetingValue, 'greeting');
        setState(() {
          greeting = greetingValue;
        });
        prefs.reload();
        Navigator.pop(context);
      },
          icon: Icon(Icons.arrow_back)),
      ),
      extendBody: true,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8.0),
              child: Center(
                child: Text('Password Settings'),
              ),
            ),
            spacer,
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                obscureText: false,
                controller: passwordController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Enter a secure password'),
                onChanged: (text) {
                  passwordValue = text;
                },
              ),
            ),
            spacer,
      SwitchListTile(value: isChecked, onChanged: (bool value) {
        isChecked = value;
        passwordEnabled = value;
        setState(() {
          if (value) {
            lockIcon = Icon(Icons.lock);
            passwordLabelText = "Password Enabled";
            prefs.setBool('passwordEnabled', value);

          }
          else if (!value) {
            lockIcon = Icon(Icons.lock_open);
            passwordLabelText = "Password Disabled";
            prefs.setBool('passwordEnabled', value);

          }
      passwordLabelWidget = Text(passwordLabelText);
        });
      },
        title: passwordLabelWidget,
        secondary: lockIcon,
      ),
            spacer,
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8.0),
              child: Text('Customization Settings'),),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                obscureText: false,
                controller: greetingController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Custom Greeting',
                    hintText: 'Enter your name here'),
                onChanged: (text) {
                  greetingValue = text;
                },
              ),
            ),
            spacer,
            ElevatedButton(onPressed: () {
              setState(() {
                prefs.setBool('passwordEnabled', isChecked);
                saveSettings(passwordValue, 'loginPassword');
                saveSettings(greetingValue, 'greeting');
                greeting = greetingValue;
           prefs.reload();
          Navigator.pop(context);
              });

            }, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }

}

///This is for check box related stuff
Color getColor(Set<MaterialState> states) {
  const Set<MaterialState> interactiveStates = <MaterialState>{
    MaterialState.pressed,
    MaterialState.hovered,
    MaterialState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.blue;
  }
  return Colors.red;
}