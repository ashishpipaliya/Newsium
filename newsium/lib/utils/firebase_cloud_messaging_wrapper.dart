import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_text/link_text.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:newsium/layout/news/news_page.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/services/notification_service.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:platform_device_id/platform_device_id.dart';

Future<void> onBackgroundHandler(RemoteMessage? message) async {
  await Firebase.initializeApp();
}

class FireBaseCloudMessagingWrapper extends Object {
  RemoteMessage? _pendingNotification;

  FirebaseMessaging? _fireBaseMessaging;
  String _fcmToken = "123";

  String get fcmToken => _fcmToken;
  bool _isAppStarted = false;

  factory FireBaseCloudMessagingWrapper() {
    return _singleton;
  }

  static final FireBaseCloudMessagingWrapper _singleton =
      new FireBaseCloudMessagingWrapper._internal();

  FireBaseCloudMessagingWrapper._internal() {
    print("===== Firebase Messaging created =====");
    _fireBaseMessaging = FirebaseMessaging.instance;
    firebaseCloudMessagingListeners();
  }

  Future<String> getFCMToken() async {
    try {
      String? token = await _fireBaseMessaging?.getToken();
      if (token != null && token.isNotEmpty) {
        print("===== FCM Token :: $token =====");
        _fcmToken = token;
      }
      return _fcmToken;
    } catch (e) {
      print("Error :: ${e.toString()}");
      return '';
    }
  }

  // Future<void> saveTokens(var token) async {
  //   try {
  //     String? deviceId = await PlatformDeviceId.getDeviceId;
  //     print('----------------------------- $deviceId');
  //     await FirebaseFirestore.instance.collection('tokens').doc(deviceId).set({
  //       'token': token,
  //       'created_at': DateTime.now().toUtc().millisecondsSinceEpoch,
  //       'device_type': Platform.isAndroid ? 'android' : 'ios'
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  Future<void> saveTokenToMongoDB(var token) async {
    try {
      String? deviceId = await PlatformDeviceId.getDeviceId;
      print('----------------------------- $deviceId');
      var db = await Db.create(
          'mongodb+srv://username:password@cluster0.ji7mu.mongodb.net/tokens');
      await db.open();
      var collection = db.collection('tokens');
      var data = {
        '_id': deviceId,
        'token': token,
        'created_at': DateTime.now().toUtc().millisecondsSinceEpoch,
        'device_type': Platform.isAndroid ? 'android' : 'ios'
      };
      var exists = await collection.findOne({'_id': deviceId});
      if (exists == null) {
        await collection.insert(data);
      } else {
        await collection.update(where.eq('_id', deviceId),
            modify.set('token', token).set('created_at', data['created_at']),
            multiUpdate: true);
      }
      db.close();
    } catch (e) {
      print(e);
    }
  }

  void firebaseCloudMessagingListeners() {
    performPendingNotificationOperation();
    _fireBaseMessaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (this._isAppStarted) {
          this.notificationOperation(payload: message);
        } else {
          this._pendingNotification = message;
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("onMessage :: ${message.toString()}");
      NotificationService.displayNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      notificationOperation(payload: message);
    });

    FirebaseMessaging.onBackgroundMessage(onBackgroundHandler);
  }

  performPendingNotificationOperation() {
    this._isAppStarted = true;
    print("Check Operation for pending notification");
    if (this._pendingNotification == null) {
      return;
    }
    this.notificationOperation(payload: this._pendingNotification);
    this._pendingNotification = null;
  }

  // void displayNotificationView({RemoteMessage? payload}) {
  //   String title = "Newsium";
  //   String body = "";
  //   // Map<String, dynamic>? data = {};
  //
  //   title = payload?.notification?.title ?? '';
  //   body = payload?.notification?.body ?? '';
  //   // data = payload?.data;
  //
  //   print("Display notification view");
  //
  //   showOverlayNotification((BuildContext _cont) {
  //     return NotificationView(
  //         title: title,
  //         subTitle: body,
  //         onTap: (isAllow) {
  //           OverlaySupportEntry.of(_cont)?.dismiss();
  //           if (isAllow) {
  //             this.notificationOperation(payload: payload);
  //           }
  //         });
  //   }, duration: Duration(milliseconds: 5000));
  // }

// when app is terminated
  // Future<void> onBackgroundHandler(RemoteMessage? message) async {
  //   print(message!.notification);
  // }

// handle notification actions
  void notificationOperation({RemoteMessage? payload}) {
    print(" Notification tap detected ");

    Map<String, dynamic> notification = Map<String, dynamic>();
    notification = payload!.data;
    handleRedirect(payload: json.encode(notification));
  }

  static int getTabIndex(String? category) {
    int index = 0;
    final catList = categories
        .map((c) => c.toLowerCase().trim().replaceAll('-', ''))
        .toList();
    index = catList.indexOf(category!);
    return index;
  }

  static void handleRedirect({String? payload}) {
    Map<String, dynamic> notification = json.decode(payload!);

    print(notification);
    if (notification['category'] == 'update') {
      Get.defaultDialog(
        title: notification['messageTitle'] ?? 'Hey There',
        content: LinkText(
          notification['message'],
          textStyle: TextStyle(color: AppColor.darkTextColor),
          linkStyle: TextStyle(color: AppColor.blueColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(notification['messageButtonText']),
          ),
        ],
      );
    } else if (notification['category'] == 'top_stories') {
      Get.offNamed('/FeedScreen');
    } else {
      Get.offAllNamed('/FeedScreen');
      Get.to(
        () => CategoryWiseNewsPage(
          tabIndex: getTabIndex(notification['category']),
        ),
      );
    }
  }
}
