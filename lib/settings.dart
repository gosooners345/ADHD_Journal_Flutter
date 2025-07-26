import 'dart:io';
import 'package:adhd_journal_flutter/project_resources/global_vars_andpaths.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'notifications_packages/notification_controller.dart';
import 'package:adhd_journal_flutter/project_resources/project_colors.dart';
import 'package:adhd_journal_flutter/project_resources/project_strings_file.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
//import 'package:launch_review/launch_review.dart';
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
  late Icon bellIcon;
final InAppReview inAppReview = InAppReview.instance;
  //Preference Values
  String passwordValue = userPassword;
  String passwordHintValue = passwordHint;
  String greetingValue = '';
  Text passwordLabelWidget = const Text('');
  Text syncTextWidget = const Text('');
  late SwitchListTile passwordEnabledTile;
  String notifyText = '';

  //Visual changes based on parameter values
  String passwordLabelText = 'Password Enabled';
  String syncTextLabelText = "Turn backup on/off";
  late Icon lockIcon;
  Icon syncIcon = Icon(
    Icons.sync,
    color: Color(colorSeed),
  );

  // Convenience Widget for spacing and alignment
  SizedBox spacer = const SizedBox(height: 16, width: 8);

  //Text Controllers
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController greetingController = TextEditingController();
  late TextEditingController passwordHintController = TextEditingController();

  Color currentColor = AppColors.mainAppColor;
  Color pickerColor = AppColors.mainAppColor;

  void changeColor(ThemeSwap swapper, int value) {
    colorSeed = value;
    saveColorSettings(swapper, value);
  }

  @override
  void initState() {
    super.initState();

// Parameter Value setting

    if (passwordHint == " ") {
      passwordHint = '';
    }
    notificationsAllowed = Global.prefs.getBool('notifications') ?? false;
    setState(() {
      if (notificationsAllowed) {
        notifyText =
            'Notifications Turned on, Click here to change the schedule or turn them off.\r\n'
            'Hit cancel to turn them off when the time picker pops up.';
        bellIcon = Icon(
          Icons.notifications_active,
          color: Color(colorSeed),
        );
      } else {
        notifyText = 'Click here to turn on notification reminders';
        bellIcon = Icon(
          Icons.notifications,
          color: Color(colorSeed),
        );
      }
      greetingController = TextEditingController(text: greeting);
      passwordController = TextEditingController(text: userPassword);
      passwordHintController = TextEditingController(text: passwordHint);
      if (isPasswordChecked) {
        lockIcon = Icon(
          Icons.lock,
          color: Color(colorSeed),
        );
        passwordLabelText = "Password Enabled";
      } else {
        lockIcon = Icon(
          Icons.lock_open,
          color: Color(colorSeed),
        );
        passwordLabelText = "Password Disabled";
      }
      passwordLabelWidget = Text(passwordLabelText);
      if (Global.userActiveBackup) {
        syncIcon = Icon(
          Icons.sync,
          color: Color(colorSeed),
        );
        syncTextLabelText = "Backup and Sync to Drive Enabled";
      } else {
        syncIcon = Icon(
          Icons.sync_disabled,
          color: Color(colorSeed),
        );
        syncTextLabelText = "Backup and Sync to Drive Disabled";
      }
      syncTextWidget = Text(syncTextLabelText);
    });
  }

  ///Save string values into the preferences
  void saveSettings(String value, String key) async {
    Global.encryptedSharedPrefs.setString(key, value);
    await Global.encryptedSharedPrefs.setString(key, value);
    Global.encryptedSharedPrefs.reload();
  }

  void saveSettings2(bool value, String key) async {
    Global.prefs.setBool(key, value);
  }

  void saveColorSettings(ThemeSwap swapper, int colorValue) async {
    setState(() {
      swapper.themeColor = colorValue;
    });
  }

  void setColor(Color color) {
    setState(() {
      colorSeed = color.value;
      currentColor = color;
    });
  }

  // USE ONLY IF YOU NEED TO RESET KEYS ON DEVICE. A FILE WILL BE ON THE DRIVE WARNING OF OLD KEYS
// This will need to be modified to permit multiple services to be used
  void resetRSAKeys() async {
    await Future.sync(() => Global.googleDrive.deleteOutdatedBackups(Global.prefsName));

    await Future.sync(() => Global.googleDrive.deleteOutdatedBackups(".pem"))
        .whenComplete(
      () => Global.preferenceBackupAndEncrypt.generateRSAKeys(),
    );
    await Future.delayed(const Duration(seconds: 2), () {
      Global.preferenceBackupAndEncrypt.encryptRsaKeysAndUpload(Global.googleDrive);
    });
    await Future.delayed(const Duration(seconds: 5), () {
      Global.preferenceBackupAndEncrypt.downloadRSAKeys(Global.googleDrive);
    });
  }

  /// The display for the screen
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeSwap>(builder: (context, swapper, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: IconButton(
              onPressed: () {
                Global.prefs.setBool('passwordEnabled', isPasswordChecked);
                if (passwordHint == '') {
                  passwordHint = ' ';
                }
                passwordEnabled = isPasswordChecked;
                saveSettings(passwordHint, 'passwordHint');
                saveSettings(userPassword, 'loginPassword');
                Global.prefs.setString('greeting', greeting);
                if (kDebugMode) {
                  print(passwordHint);
                }
                Future.delayed(const Duration(milliseconds: 50),
                    () => Navigator.pop(context));
              },
              icon: backArrowIcon),
        ),
        extendBody: true,
        body:


        ListView(
          children: <Widget>[
            ListTile(
              iconColor: Color(swapper.isColorSeed),
              leading: const Icon(Icons.display_settings),
              title: const Text(
                'Customization Settings',
                textScaleFactor: 1.15,
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
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
              color: Color(swapper.isColorSeed),
            ),
            spacer,
            ListTile(
              leading: Icon(
                Icons.color_lens,
                color: Color(swapper.isColorSeed),
              ),
              title: const Text(
                "Click here to change the application theme color",
              ),
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext builder) {
                      return AlertDialog(
                        title: const Text(
                            "Pick a new color to theme your journal with."),
                        content: SingleChildScrollView(
                          child: MaterialPicker(
                            pickerColor: pickerColor,
                            onColorChanged: setColor,
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  currentColor = pickerColor;
                                  changeColor(swapper, colorSeed);
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text("Set theme color")),
                        ],
                      );
                    });
              },
            ),
            spacer,
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            spacer,

            ListTile(
                leading: bellIcon,
                title: Text(notifyText),
                onTap: () {
                  AwesomeNotifications()
                      .isNotificationAllowed()
                      .then((isAllowed) {
                    if (!isAllowed) {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title:
                                    const Text("Allow reminder notifications?"),
                                content: const Text(
                                    "Would you like to be reminded to journal daily? If so, hit allow."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        AwesomeNotifications()
                                            .requestPermissionToSendNotifications()
                                            .then(
                                          (_) async {
                                            Global.prefs.setBool(
                                                "notifications", true);
                                            notifyText =
                                                'Notifications Turned on, Click here to change the schedule or turn them off.\r\n'
                                                'Hit cancel to turn them off when the time picker pops up.';
                                            setState(() {
                                              bellIcon = Icon(
                                                Icons.notifications_active,
                                                color: Color(colorSeed),
                                              );
                                            });
                                          },
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Text("Allow")),
                                  TextButton(
                                    onPressed: () {
                                      Global.prefs.setBool("notifications", false);
                                      notifyText =
                                          'Click here to turn on notification reminders';
                                      setState(() {
                                        bellIcon = Icon(
                                          Icons.notifications,
                                          color: Color(colorSeed),
                                        );
                                      });
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Don\'t Allow',
                                    ),
                                  ),
                                ],
                              ));
                    } else {
                      Global.prefs.setBool("notifications", true);
                      notificationsAllowed =
                          Global.prefs.getBool('notifications') ?? true;
                      NotificationController.cancelNotifications()
                          .then((_) async {
                        TimeOfDay? scheduleReminder = await showTimePicker(
                            context: context, initialTime: TimeOfDay.now());

                        if (scheduleReminder != null) {
                          NotificationController.scheduleNewNotification(
                              scheduleReminder);
                          setState(() {
                            bellIcon = Icon(
                              Icons.notifications_active,
                              color: Color(colorSeed),
                            );
                            notifyText =
                                'Notifications Turned on, Click here to change the schedule or turn them off.\r\n'
                                'Hit cancel to turn them off when the time picker pops up.';
                          });
                          String AMPM =
                              scheduleReminder.hour > 12 ? "PM" : "AM";
                          showMessage("Reminder Created for ${scheduleReminder.hourOfPeriod}:${scheduleReminder.minute}$AMPM");
                          if (kDebugMode) {
                            print("Notification schedule created");
                          }
                        } else {
                          AwesomeNotifications().cancelSchedulesByChannelKey(
                              'adhd_journal_scheduled');
                          showMessage("Notification schedule cancelled");

                          Global.prefs.setBool("notifications", false);
                          notificationsAllowed =
                              Global.prefs.getBool('notifications') ?? false;
                          notifyText =
                              'Click here to turn on notification reminders';
                          setState(() {
                            bellIcon = Icon(
                              Icons.notifications,
                              color: Color(colorSeed),
                            );
                          });
                        }
                      });
                    }
                  });
                }),

            spacer,
            Divider(
              height: 2.0,
              thickness: 2.0,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              iconColor: Color(swapper.isColorSeed),
              leading: const Icon(Icons.security),
              title: const Text(
                'Security Settings',
                textScaleFactor: 1.15,
              ),
            ),
            Divider(
              height: 1.0,
              thickness: .5,
              color: Color(swapper.isColorSeed),
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
                  if (text != '' || text != ' ') {
                    userPassword = text;
                  }
                },
              ),
            ),
            spacer,
            //Password tile
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            spacer,
            ListTile(
              title: TextField(
                obscureText: false,
                controller: passwordHintController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password Hint',
                    hintText: 'Enter a password hint here.'),
                onChanged: (text) {
                  if (text != '' || text != ' ') {
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
              color: Color(swapper.isColorSeed),
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
                      color: Color(swapper.isColorSeed),
                    );
                    passwordLabelText = "Password Enabled";
                    Global.prefs.setBool('passwordEnabled', value);
                    if (kDebugMode) {
                      print(value);
                    }
                  } else if (!value) {
                    lockIcon = Icon(
                      Icons.lock_open,
                      color: Color(swapper.isColorSeed),
                    );
                    passwordLabelText = "Password Disabled";
                    Global.prefs.setBool('passwordEnabled', value);
                    if (kDebugMode) {
                      print(value);
                    }
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
              color: Color(swapper.isColorSeed),
            ),
            //Sync

            ListTile(
              title: const Text(
                  "Advanced Settings - Click here if you need to reset your RSA encryption keys for backup and sync"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext builder) {
                    return AlertDialog(
                      title: const Text(
                        "Reset RSA Keys for backup and sync.",
                      ),
                      content: const Text(Global.reset_RSA_Key_Dialog_Message_String),
                      actions: [
                        ElevatedButton(
                            onPressed: () async {
                              if (Global.userActiveBackup == true) {
                                Navigator.of(context).pop();
                                await Future.sync(() => resetRSAKeys())
                                    .whenComplete(() {
                                  showMessage("Your keys have been reset");
                                });
                              } else {
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text("Yes")),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("No"),
                        )
                      ],
                    );
                  },
                );
              },
            ),
            spacer,
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            spacer,
            // Backup & Sync Section , OneDrive & iCloud will need to be added here
            SwitchListTile(
              value: Global.userActiveBackup,
              onChanged: (bool value) {
                Global.userActiveBackup = value;
                Global.userActiveBackup = value;
                setState(() {
                  if (value == true) {
                    syncIcon = Icon(
                      Icons.sync,
                      color: Color(swapper.isColorSeed),
                    );
                    syncTextLabelText = "Backup and Sync to Drive Enabled";
                    Global.prefs.setBool('testBackup', value);
                    if (kDebugMode) {
                      print("Backup and sync is $value");
                    }
                    getDriveAgent();
                  } else if (value == false) {
                    syncIcon = Icon(
                      Icons.sync_disabled,
                      color: Color(swapper.isColorSeed),
                    );
                    syncTextLabelText = "Backup and Sync to Drive Disabled";
                    Global.prefs.setBool('testBackup', value);
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
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              iconColor: Color(swapper.isColorSeed),
              leading: const Icon(Icons.info_outline),
              title: const Text(
                'Application info',
                textScaleFactor: 1.15,
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),

            ListTile(
              iconColor: Color(swapper.isColorSeed),
              leading: const Icon(Icons.info_outline),
              title: Text(
                'You are running version $buildInfo',
                textAlign: TextAlign.left,
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
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
              iconColor: Color(swapper.isColorSeed),
              title: const Text('Contact Me'),
              subtitle: const Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      "Tell me about your experience using this app or request new features here!",
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              onTap: () {
                inAppReview.openStoreListing(appStoreId: '1624483395');

              },
              title: const Text('Rate my app'),
              iconColor: Color(swapper.isColorSeed),
              leading: const Icon(Icons.star),
            ),
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),
            ListTile(
              iconColor: Color(swapper.isColorSeed),
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
              color: Color(swapper.isColorSeed),
            ),
           /* ListTile(
              iconColor: Color(swapper.isColorSeed),
              leading: const Icon(Icons.book),
              title: const Text('Resources'),
              subtitle: const Text(resource_link_title),
              onTap: () {
                Navigator.pushNamed(context, '/resources');
              },
            ),*/
            Divider(
              height: 1.0,
              thickness: 0.5,
              color: Color(swapper.isColorSeed),
            ),

            ListTile(
              leading: Image.asset('images/GoogleDriveLogo.png'),
              title: const Text(''),
              subtitle: const Text(
                  'Google Drive is a trademark of Google Inc. Use of this trademark is subject to Google Permissions.'),
              onTap: () {},
            ),
          ],
        ),
      );
    });
  }

  void emailDev() async {
    final Email email = Email(
        subject: "Bugs and Feature Request for ADHD Journal version $buildInfo",
        body: '',
        recipients: ['boomersooner12345@gmail.com'],
        isHTML: false);
    await FlutterEmailSender.send(email);
  }

//Onedrive agent method needed
  void getDriveAgent() async {
    Global.googleDrive.client = await Global.googleDrive.getHttpClient();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
