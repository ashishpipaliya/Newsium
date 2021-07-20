import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newsium/layout/news/news_page.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/utils/notification_view.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:mongo_dart/mongo_dart.dart';

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

  Future<void> saveTokenToMongoDB(var token) async {
    try {
      String? deviceId = await PlatformDeviceId.getDeviceId;
      print('----------------------------- $deviceId');
      var db = await Db.create(
          'mongodb+srv://ashish:ashdeveloper@cluster0.ji7mu.mongodb.net/tokens');
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
    print(" Notification tap detected ");

    Map<String, dynamic> notification = Map<String, dynamic>();
    notification = payload!.data;

    _handleRedirect(category: payload.data['category']);
  }

  int getTabIndex(String? category) {
    int index = 0;
    final catList = categories
        .map((c) => c.toLowerCase().trim().replaceAll('-', ''))
        .toList();

    index = catList.indexOf(category!);
    return index;
  }

  _handleRedirect({String? category}) {
    if (category == 'all_news') {
      Get.toNamed('/FeedScreen');
    } else {
      // Get.toNamed('/FeedScreen');
      Future.delayed(Duration(milliseconds: 100), () {
        Get.to(() => CategoryWiseNewsPage(tabIndex: getTabIndex(category)));
      });
    }
  }
}
