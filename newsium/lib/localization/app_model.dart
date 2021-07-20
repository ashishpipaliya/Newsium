import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:newsium/utils/firebase_cloud_messaging_wrapper.dart';

class AppModel extends ChangeNotifier {
  AppModel() {
    this._setupInitial();
  }

  Future _setupInitial() async {
    print('---------------initial setup');
    await Firebase.initializeApp();

    // Update FCM Token
    Future.delayed(Duration(seconds: 3), () async {
      String fcmToken = await FireBaseCloudMessagingWrapper().getFCMToken();
      FireBaseCloudMessagingWrapper().saveTokenToMongoDB(fcmToken);
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    });
    notifyListeners();
  }
}
