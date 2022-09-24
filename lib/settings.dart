import 'dart:io';

import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:flutter/foundation.dart';
import 'package:launch_review/launch_review.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_start_package/splash_screendart.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'app_start_package/login_screen_file.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

/// To Do list: Add more stuff like customization of list display, theme choices, etc.
String buildNumber = '';

class _SettingsPage extends State<SettingsPage> {
  //Native code handling methods

  //Parameter setting stuff
  bool isChecked = false;
  //Preference Values
  String passwordValue = userPassword;
 String passwordHintValue = passwordHint;
  String greetingValue = '';
  Text passwordLabelWidget = const Text('');
  bool passwordEnabled = false;
  Text syncTextWidget = const Text('');
  late SwitchListTile passwordEnabledTile;
  //Visual changes based on parameter values
  String passwordLabelText = 'Password Enabled';
  String  syncTextLabelText = "Turn backup on/off";
  late Icon lockIcon;
  Icon syncIcon=Icon(Icons.sync,color: Color(colorSeed),);
  // Convenience Widget for spacing and alignment
  SizedBox spacer = const SizedBox(height: 16, width: 8);
  //Text Controllers
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController greetingController = TextEditingController();
  late TextEditingController passwordHintController = TextEditingController();

  Color currentColor = AppColors.mainAppColor;
  Color pickerColor = AppColors.mainAppColor;
  void changeColor(ThemeSwap swapper,int value) {
    setState(() {

    });
    colorSeed=value;
    saveColorSettings(swapper,value);
  }

  @override
  void initState() {
    super.initState();

// Parameter Value setting

if(passwordHint ==" "){
  passwordHint = '';
}

    setState(() {
      greetingController = TextEditingController(text: greeting);
      passwordController = TextEditingController(text: userPassword);
      passwordHintController = TextEditingController(text: passwordHint);
      if (isPasswordChecked) {
        lockIcon = Icon(
          Icons.lock,
          color: Color(colorSeed),
        );
        passwordLabelText = "Password Enabled";
      //  passwordLabelWidget = Text(passwordLabelText);
      } else {
        lockIcon = Icon(
          Icons.lock_open,
          color: Color(colorSeed),
        );
        passwordLabelText = "Password Disabled";
       // passwordLabelWidget = Text(passwordLabelText);
      }
      passwordLabelWidget = Text(passwordLabelText);
      if(userActiveBackup){
        syncIcon =Icon(Icons.sync,color: Color(colorSeed),);
        syncTextLabelText = "Backup and Sync to Drive Enabled";
      }
      else{
        syncIcon=Icon(Icons.sync_disabled,color: Color(colorSeed),);
        syncTextLabelText = "Backup and Sync to Drive Disabled";
      }
      syncTextWidget = Text(syncTextLabelText);
    });
  }

  ///Save string values into the preferences
  void saveSettings(String value, String key) async {
    encryptedSharedPrefs.setString(key, value);
    await   encryptedSharedPrefs.setString(key, value);
  encryptedSharedPrefs.reload();

  }
  void saveSettings2(bool value, String key) async {
    prefs.setBool(key, value);
  }
  void saveColorSettings(ThemeSwap swapper,int colorValue) async{

    setState(() {
      swapper.themeColor = colorValue;

    });

  }
  void setColor(Color color){
    setState(() {
      colorSeed = color.value;
      currentColor = color;
    });
  }


  /// The display for the screen
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(
        builder: (context, ThemeSwap themeNotifier, child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
            onPressed: () {
              prefs.setBool('passwordEnabled', isPasswordChecked);
              if(passwordHint == ''){
                passwordHint = ' ';
              }
              saveSettings(passwordHint, 'passwordHint');
              saveSettings(userPassword, 'loginPassword');
              prefs.setString('greeting', greeting);
              if(kDebugMode){
                print(passwordHint);
              }
              Future.delayed( const Duration(milliseconds: 50), () => Navigator.pop(context));
            },
            icon: backArrowIcon),
      ),
      extendBody: true,
      body: ListView(
        children: <Widget>[
          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.display_settings),
            title: const Text(
              'Customization Settings',
              textScaleFactor: 1.15,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          spacer,
          ListTile(
            title: TextField(
              obscureText: false,
              controller: greetingController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Greeting',
                  hintText: 'Enter your name here'),
              onChanged: (text) {
                greeting = text;
              },
            ),
          ),
          spacer,
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(colorSeed),
          ),
          spacer,
          ListTile(
            title:const Text("Application Theme Colors",),
            onTap: (){
showDialog(context: context, builder: (BuildContext builder){
  return AlertDialog(
    title: Text("Pick a new color to theme your journal with."),
    content: SingleChildScrollView(
      child: MaterialPicker(
        pickerColor: pickerColor,
        onColorChanged: setColor,
      ),

    ),
    actions: [
      ElevatedButton(onPressed: (){
        setState(() {
          currentColor = pickerColor;
        changeColor(themeNotifier,colorSeed );

        });
        Navigator.of(context).pop();

      }, child: Text("Set theme color")),
    ],
  );
});
            },
          ),
          spacer,
          Divider(
            height: 2.0,
            thickness: 2.0,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.security),
            title: const Text(
              'Security Settings',
              textScaleFactor: 1.15,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: .5,
            color: Color(themeNotifier.isColorSeed),
          ),
          spacer,
          //Password tile
          ListTile(
            title: TextField(
              obscureText: false,
              controller: passwordController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                  hintText: 'Enter a secure password'),
              onChanged: (text) {
                if(text != '' || text !=' '){
                userPassword = text;
                }
              },
            ),
          ),
          spacer,
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),spacer,
          ListTile(
            title: TextField(
              obscureText: false,
              controller:passwordHintController,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password Hint',
                  hintText: 'Enter a password hint here.'),
              onChanged: (text) {
                if(text!= '' || text !=' '){
                passwordHint = text;
                } else {
                  passwordHint = ' ';
                }
              },
            ),
          ),
          spacer,
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          SwitchListTile(
            value: isPasswordChecked,
            onChanged: (bool value) {
              isPasswordChecked = value;
              passwordEnabled = value;
              setState(() {
                if (value) {
                  lockIcon = Icon(
                    Icons.lock,
                    color: Color(themeNotifier.isColorSeed),
                  );
                  passwordLabelText = "Password Enabled";
                  prefs.setBool('passwordEnabled', value);
                  print(value);
                } else if (!value) {
                  lockIcon = Icon(
                    Icons.lock_open,
                    color: Color(themeNotifier.isColorSeed),
                  );
                  passwordLabelText = "Password Disabled";
                  prefs.setBool('passwordEnabled', value);
                  print(value);
                }
                passwordLabelWidget = Text(passwordLabelText);
              });
            },
            title: passwordLabelWidget,
            secondary: lockIcon,
          ),
          spacer,
          Divider(
            height: 2.0,
            thickness: 2.0,
            color: Color(themeNotifier.isColorSeed),
          ),
          //Sync
          spacer,
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          SwitchListTile(
            value: userActiveBackup,
            onChanged: (bool value) {
              userActiveBackup = value;
              userActiveBackup = value;
              setState(() {
                if (value) {
                  syncIcon = Icon(Icons.sync,
                    color: Color(themeNotifier.isColorSeed),
                  );
                  syncTextLabelText = "Backup and Sync to Drive Enabled";
                  prefs.setBool('testBackup', value);
                  if (kDebugMode) {
                    print("Backup and sync is $value");
                  }
                } else if (!value) {
                  syncIcon = Icon(Icons.sync_disabled,
                    color: Color(themeNotifier.isColorSeed),
                  );
                  syncTextLabelText = "Backup and Sync for Drive Disabled";
                  prefs.setBool('testBackup', value);
                  print("Backup and Sync is $value");
                }
                syncTextWidget = Text(syncTextLabelText);
              });
            },
            title: syncTextWidget,
            secondary: syncIcon,
          ),
          spacer,
          Divider(
            height: 2.0,
            thickness: 2.0,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.info_outline),
            title: const Text(
              'Application info',
              textScaleFactor: 1.15,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),

          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.info_outline),
            title: Text(
              'You are running version $buildInfo',
              textAlign: TextAlign.left,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            onTap: () {
              try {
                emailDev();
              } on Exception catch (ex) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ex.toString()),
                    duration: const Duration(milliseconds: 1500),
                    width: 280.0,
                    // Width of the SnackBar.
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                    ),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                );
              }
            },
            iconColor: Color(themeNotifier.isColorSeed),
            title: const Text('Contact Me'),
            subtitle: Row(
              children: const [
                Expanded(
                  flex: 1,
                  child: Text(
                    "Tell me about your experience using this app or request new features here!",
                    softWrap: true, /*textScaleFactor: 1.15,*/
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            onTap: () {
              if (Platform.isIOS) {
                LaunchReview.launch(iOSAppId: '1624483395');
              } else {
                LaunchReview.launch(
                    androidAppId: 'com.activitylogger.release1');
              }
            },
            title: const Text('Rate my app'),
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.star),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.help),
            title: const Text("How to use app?"),
            subtitle: const Text(
                "Click here to learn how to get the most out of the app."),
            onTap: () {
              Navigator.pushNamed(context, '/tutorials');
            },
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: Color(themeNotifier.isColorSeed),
          ),
          ListTile(
            iconColor: Color(themeNotifier.isColorSeed),
            leading: const Icon(Icons.book),
            title: const Text('Resources'),
            subtitle: const Text(
                resource_link_title),
            onTap: () {
              Navigator.pushNamed(context, '/resources');
            },
          )
        ],
      ),
    );
  });
}

  void emailDev() async {
    final Email email = Email(
        subject:
            "Bugs and Feature Request for ADHD Journal version $buildInfo",
        body: '',
        recipients: ['boomersooner12345@gmail.com'],
        isHTML: false);
    await FlutterEmailSender.send(email);
  }
}
