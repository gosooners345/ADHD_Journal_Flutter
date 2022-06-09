import 'dart:io';

import 'package:adhd_journal_flutter/project_colors.dart';
import 'package:adhd_journal_flutter/project_strings_file.dart';
import 'package:launch_review/launch_review.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter/material.dart';
import 'splash_screendart.dart';
import 'login_screen_file.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPage();
}

/// To Do list: Add more stuff like customization of list display, theme choices, etc.
String buildNumber = '';

class _SettingsPage extends State<SettingsPage> {
  //Native code handling methods
  static const platform =
      MethodChannel('com.activitylogger.release1/ADHDJournal');

  //Parameter setting stuff
  bool isChecked = false;
  //Preference Values
  String passwordValue = userPassword;

  String greetingValue = '';
  Text passwordLabelWidget = const Text('');
  bool passwordEnabled = false;
  late SwitchListTile passwordEnabledTile;
  //Visual changes based on parameter values
  String passwordLabelText = 'Password Enabled';
  late Icon lockIcon;
  // Convenience Widget for spacing and alignment
  SizedBox spacer = const SizedBox(height: 16, width: 8);
  //Text Controllers
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController greetingController = TextEditingController();

  @override
  void initState() {
    super.initState();

// Parameter Value setting
    greetingValue = prefs.getString('greeting') ?? '';

    setState(() {
      greetingController = TextEditingController(text: greetingValue);
      passwordController = TextEditingController(text: passwordValue);
      if (isPasswordChecked) {
        lockIcon = Icon(
          Icons.lock,
          color: AppColors.mainAppColor,
        );
        passwordLabelText = "Password Enabled";
        passwordLabelWidget = Text(passwordLabelText);
      } else {
        lockIcon = Icon(
          Icons.lock_open,
          color: AppColors.mainAppColor,
        );
        passwordLabelText = "Password Disabled";
        passwordLabelWidget = Text(passwordLabelText);
      }
    });
  }

  ///Save string values into the preferences
  void saveSettings(String value, String key) async {
    encryptedSharedPrefs.setString(key, value);
  }

  void saveSettings2(bool value, String key) async {
    prefs.setBool(key, value);
  }

  /// The display for the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
            onPressed: () {
              prefs.setBool('passwordEnabled', isPasswordChecked);
              saveSettings(passwordValue, 'loginPassword');
              prefs.setString('greeting', greetingValue);
              setState(() {
                greeting = greetingValue;
              });

              userPassword = passwordValue;
              Navigator.pop(context);
            },
            icon: backArrowIcon),
      ),
      extendBody: true,
      body: ListView(
        children: <Widget>[
          ListTile(
            iconColor: AppColors.mainAppColor,
            leading: const Icon(Icons.display_settings),
            title: const Text(
              'Customization Settings',
              textScaleFactor: 1.15,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
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
                greetingValue = text;
              },
            ),
          ),
          spacer,
          Divider(
            height: 2.0,
            thickness: 2.0,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            iconColor: AppColors.mainAppColor,
            leading: const Icon(Icons.security),
            title: const Text(
              'Security Settings',
              textScaleFactor: 1.15,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: .5,
            color: AppColors.mainAppColor,
          ),
          spacer,
          ListTile(
            title: TextField(
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
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
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
                    color: AppColors.mainAppColor,
                  );
                  passwordLabelText = "Password Enabled";
                  prefs.setBool('passwordEnabled', value);
                  print(value);
                } else if (!value) {
                  lockIcon = Icon(
                    Icons.lock_open,
                    color: AppColors.mainAppColor,
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
            color: AppColors.mainAppColor,
          ),
          ListTile(
            iconColor: AppColors.mainAppColor,
            leading: const Icon(Icons.info_outline),
            title: const Text(
              'Application info',
              textScaleFactor: 1.15,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            iconColor: AppColors.mainAppColor,
            leading: const Icon(Icons.info_outline),
            title: Text(
              'You are running version $buildInfo',
              textAlign: TextAlign.left,
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
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
            iconColor: AppColors.mainAppColor,
            title: const Text('Contact Me'),
            subtitle: Row(
              children: [
                const Expanded(
                  child: Text(
                    "Tell me about your experience using this app or request new features here!",
                    softWrap: true, /*textScaleFactor: 1.15,*/
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
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
            iconColor: AppColors.mainAppColor,
            leading: const Icon(Icons.star),
          ),
          Divider(
            height: 1.0,
            thickness: 0.5,
            color: AppColors.mainAppColor,
          ),
          ListTile(
            iconColor: AppColors.mainAppColor,
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
            color: AppColors.mainAppColor,
          ),
          ListTile(
            iconColor: AppColors.mainAppColor,
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
