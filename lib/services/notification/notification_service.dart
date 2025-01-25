import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as devtools show log;
import 'dart:convert';

//This class handles the notification.
// - init notifications : to initialize the notifications
// - handle notification: redirection happening when the user clicks on the notification
// - notifications details: what the notification will look like
// - schedule notification: the notication will arrive at a set time

class NotificationService {
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOS =  const DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
              
              devtools.log("The user clicked on the notification");
              devtools.log("Payload of the notification: ${notificationResponse.payload}");
              handleNotification(notificationResponse.payload);
            },

        );
  }

  static void handleNotification(String? payload) {
    devtools.log('Handle Notification: $payload');
    navigatorKey.currentState?.pushNamed(
      showNotificationRoute,
      arguments: payload
    );
    
  }

  static Future notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max, icon: 'ic_launcher'),
        iOS: DarwinNotificationDetails());
  }

  static Future showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
        id, title, body, await notificationDetails());
  }

  static void scheduleNotification(
      {int id = 0,
      String? title,
      String? body,
      String? payLoad,
      required DateTime scheduledNotificationDateTime}) async {
        devtools.log("Schedule Datetime: $scheduledNotificationDateTime");
        devtools.log("Schedule time TZDateTime: ${tz.TZDateTime.from(
          scheduledNotificationDateTime,
          tz.getLocation('Europe/Paris'),
        )}");
        try{
          final String encodedPayload = jsonEncode({
              'body': body,
              'note_id': payLoad,
              });

            devtools.log('Trying to schedule a notification...');
            return notificationsPlugin.zonedSchedule(
                id,
                title,
                body,
                tz.TZDateTime.from(
                  scheduledNotificationDateTime,
                  tz.getLocation('Europe/Paris'),
                ),
                await notificationDetails(),
                payload: encodedPayload,
                androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                uiLocalNotificationDateInterpretation:
                    UILocalNotificationDateInterpretation.absoluteTime,
                  
                );
          
        } catch (e){
          devtools.log("An error happened with the schedule notification: $e");
        }
  }
}