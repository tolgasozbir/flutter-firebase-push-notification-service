import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {

  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future _notificationDetails() async {
    return NotificationDetails(
      
      android: AndroidNotificationDetails(
        "channelId", 
        "channelName",
        channelDescription: "channelDescription",
        priority: Priority.max,
        importance: Importance.max,
        playSound: true,
        icon: 'launch_background',
      ),
      iOS: IOSNotificationDetails(presentSound: true),
    );
  }

  static Future init({bool initScheduled = false}) async {
    final android = AndroidInitializationSettings("@mipmap/ic_launcher");
    final ios = IOSInitializationSettings();
    final settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      
      settings,
    );
  }

  static Future showNotification({int id=0,String? title,String? body,String? payload}) async {
    _notifications.show(id, title, body, await _notificationDetails(),payload: payload);
  }

}