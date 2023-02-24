import 'package:awesome_notifications/awesome_notifications.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../project_resources/project_colors.dart';
import '../project_resources/project_utils.dart';
import '../project_resources/project_strings_file.dart';
import '../main.dart';

class NotificationController {

  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize('resource://drawable/res_notification_app_icon', [
      NotificationChannel(
        channelKey: 'adhd_journal',
        channelName: "ADHD Journal Reminder",
        channelDescription: "ADHD Journal Reminder Notification",
defaultColor: Colors.amberAccent,
        playSound: true,
        onlyAlertOnce: false,
        groupAlertBehavior: GroupAlertBehavior.Children,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Public,
        criticalAlerts: true,
      ),
      NotificationChannel(
        channelKey: 'adhd_journal_scheduled',
        channelName: "ADHD Journal Reminder",
        channelDescription: "ADHD Journal Reminder Notification",
        defaultColor: Colors.amberAccent,
        playSound: true,
        onlyAlertOnce: false,
        groupAlertBehavior: GroupAlertBehavior.Children,
        importance: NotificationImportance.High,
        defaultPrivacy: NotificationPrivacy.Public,
        criticalAlerts: true,
      )
    ]);
    initialAction = await AwesomeNotifications().getInitialNotificationAction(
        removeFromActionEvents: false);
  }


//Notifications begin here
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (
    receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction
    ) {
      // For background actions, you must hold the execution until the end
      print('Message sent via notification input: "${receivedAction
          .buttonKeyInput}"');
      await executeLongTaskInBackground();
    }
    else {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/',
              (route) =>
          (route.settings.name != '/') || route.isFirst,
          arguments: receivedAction);
    }
  }

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.gif',
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

  static Future<void> createNewNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: createUniqueId(),
            // -1 is replaced by a random number
            channelKey: 'adhd_journal',
            title: 'Daily Reminder',
            body:
            "Don't forget to journal today!",
            //bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            //largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',
            notificationLayout: NotificationLayout.Default));

  }

  static Future<void> scheduleNewNotification(NotificationWeekAndTime dateTime) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: createUniqueId(),
            // -1 is replaced by a random number
            channelKey: 'adhd_journal_scheduled',
            title: "Daily Reminder",
            body:
            "Don't forget to Journal today",
         //   bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
            //largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
            //'asset://assets/images/balloons-in-sky.jpg',

            ),
        schedule: NotificationCalendar.fromDate(date: DateTime.now().add(Duration(hours: 1))));/*NotificationCalendar(weekday:dateTime.dayOfTheWeek,hour: dateTime.timeOfDay.hour,minute: dateTime.timeOfDay.minute,repeats: true));*//*.fromDate(
            date: dateTime));*/
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}