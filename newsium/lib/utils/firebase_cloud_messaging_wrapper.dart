import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:newsium/utils/notification_view.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:platform_device_id/platform_device_id.dart';

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

  Future<void> saveTokens(var token) async {
    try {
      String? deviceId = await PlatformDeviceId.getDeviceId;
      print('----------------------------- $deviceId');
      await FirebaseFirestore.instance.collection('tokens').doc(deviceId).set({
        'token': token,
        'created_at': DateTime.now().toUtc().millisecondsSinceEpoch,
        'device_type': Platform.isAndroid ? 'android' : 'ios'
      });
    } catch (e) {
      print(e);
    }
  }

  void firebaseCloudMessagingListeners() {
    _fireBaseMessaging!.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        if (this._isAppStarted) {
          this.notificationOperation(payload: message);
        } else {
          this._pendingNotification = message;
        }
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage :: ${message.toString()}");
      Future.delayed(Duration(seconds: 1),
          () => this.displayNotificationView(payload: message));
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      notificationOperation(payload: message);
    });
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

  void displayNotificationView({RemoteMessage? payload}) {
    String title = "Newsium";
    String body = "";
    Map<String, dynamic>? data = {};

    title = payload?.notification?.title ?? '';
    body = payload?.notification?.body ?? '';
    data = payload?.data;

    print("+++++++++++++++++++++++++" + data!.toString());

    print("Display notification view");

    showOverlayNotification((BuildContext _cont) {
      return NotificationView(
          title: title,
          subTitle: body,
          onTap: (isAllow) {
            OverlaySupportEntry.of(_cont)?.dismiss();
            if (isAllow) {
              this.notificationOperation(payload: payload);
            }
          });
    }, duration: Duration(milliseconds: 5000));
  }

  void notificationOperation({RemoteMessage? payload}) {
    print(" Notification On tap Detected ");

    Map<String, dynamic> notification = Map<String, dynamic>();
    notification = payload!.data;
  }
}
