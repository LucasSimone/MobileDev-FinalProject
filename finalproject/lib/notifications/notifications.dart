import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  final channelId = 'testNotifications';
  final channelName = 'Test Notifications';
  final channelDescription = 'Test Notification Channel';

  var _flutterLocalNotificationsPlugin;

  NotificationDetails _platformChannelInfo;
  var _notificationId = 100;

  Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // setup the notification plug-in
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: onSelectNotification,
    );

    // setup a notification channel
    var androidChannelInfo = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
    );

    _platformChannelInfo = NotificationDetails(
      android: androidChannelInfo,
    );
  }

  Future onSelectNotification(var payload) async {
    if (payload != null) {
      print('onSelectNotification::payload = $payload');
    }
  }

  sendNotificationNow(String title, String body, String payload) {
    print(_flutterLocalNotificationsPlugin);
    _flutterLocalNotificationsPlugin.show(
      _notificationId++,
      title,
      body,
      _platformChannelInfo,
      payload: payload,
    );
  }

  Future<List<PendingNotificationRequest>>
      getPendingNotificationRequests() async {
    return _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
