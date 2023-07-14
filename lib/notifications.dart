import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';

class Notifications {
  final channelId = "appNotif";
  final channelName = "App Notification";
  final channelDescription = "The App Notification Channel";

  var _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationDetails? _platformChannelInfo;
  var _notificationID = 100;

  Future init() async {
    if (Platform.isIOS) {
      _requestIOSPermission();
    }

    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');

    var initializationSettingsIOS = DarwinInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) {
      return null;
    });

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    var androidChannelInfo = AndroidNotificationDetails(channelId, channelName,
        channelDescription: channelDescription);

    var iosChannelInfo = DarwinNotificationDetails();
    _platformChannelInfo =
        NotificationDetails(android: androidChannelInfo, iOS: iosChannelInfo);
  }

  Future onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse != null) {
      print(
          "onDidReceiveNotificationResponse::payload = ${notificationResponse.payload}");
    }
  }

  void sendNotification(String title, String body, String payload) {
    print(_flutterLocalNotificationsPlugin);
    _flutterLocalNotificationsPlugin.show(
        _notificationID++, title, body, _platformChannelInfo,
        payload: payload);
  }

  sendNotificationLater(
      String title, String body, String payload, TZDateTime when) {
    return _flutterLocalNotificationsPlugin.zonedSchedule(
        _notificationID++, title, body, when, _platformChannelInfo!,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        payload: payload);
  }

  sendNotificationPeriodic(String title, String body, String payload) {
    return _flutterLocalNotificationsPlugin.periodicallyShow(
        0, title, body, RepeatInterval.everyMinute, _platformChannelInfo!);
  }

  _requestIOSPermission() {
    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()!
        .requestPermissions(
          sound: true,
          badge: true,
          alert: false,
        );
  }
}
