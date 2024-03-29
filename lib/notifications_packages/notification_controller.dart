import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../project_resources/project_utils.dart';
import '../main.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications()
        .initialize('resource://drawable/res_notification_app_icon', [
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
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

//Notifications begin here
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      if (kDebugMode) {
        print(
            'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      }
      await executeLongTaskInBackground();
    } else {
      MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          '/', (route) => (route.settings.name != '/') || route.isFirst,
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
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
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
                    style: Theme.of(context)
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
                    style: Theme.of(context)
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
            channelKey: 'adhd_journal',
            title: 'Daily Reminder',
            body: "Don't forget to journal today!",
            notificationLayout: NotificationLayout.Default));
  }

  static Future<void> scheduleNewNotification(TimeOfDay? dateTime) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: createUniqueId(),
            category: NotificationCategory.Reminder,
            channelKey: 'adhd_journal_scheduled',
            title: "Daily Reminder",
            body: "Don't forget to journal today!",
            autoDismissible: true),
        schedule: NotificationCalendar(
            hour: dateTime!.hour,
            minute: dateTime.minute,
            second: 0,
            allowWhileIdle: true,
            preciseAlarm: true,
            repeats: true));
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    if (kDebugMode) {
      print("all notifications cancelled");
    }
    await AwesomeNotifications().cancelAll();
  }
}
