import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:newsium/utils/firebase_cloud_messaging_wrapper.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    final InitializationSettings _initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    _notification.initialize(
      _initializationSettings,
      onSelectNotification: (String? category) {
        if (category != null) {
          FireBaseCloudMessagingWrapper.handleRedirect(category: category);
        }
        throw NullThrownError();
      },
    );
  }

  static void displayNotification(RemoteMessage? message) async {
    try {
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'newsium',
          'newsium',
          'newsium',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      _notification.show(
        DateTime.now().millisecondsSinceEpoch ~/ 100000,
        message?.notification!.title,
        message?.notification!.body,
        notificationDetails,
        payload: message!.data['category'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }
}
