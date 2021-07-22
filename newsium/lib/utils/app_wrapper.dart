import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newsium/layout/feed_page.dart';
import 'package:newsium/localization/app_model.dart';
import 'package:newsium/utils/app_router.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import 'app_color.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({Key? key}) : super(key: key);

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  final AppModel _appModel = AppModel();

  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsObserver? observer =
        FirebaseAnalyticsObserver(analytics: analytics);

    return ChangeNotifierProvider<AppModel>.value(
      value: _appModel,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          return OverlaySupport(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              onGenerateRoute: (settings) =>
                  AppRouter.onGenerateRoute(settings),
              home: FeedScreen(),
              theme: new ThemeData(
                primaryColor: AppColor.brownColor,
              ),
              navigatorObservers: [observer],
            ),
          );
        },
      ),
    );
  }
}
