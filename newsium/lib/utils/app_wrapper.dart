import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newsium/layout/feed_page.dart';
import 'package:newsium/localization/app_model.dart';
import 'package:newsium/utils/app_router.dart';
import 'package:newsium/utils/firebase_cloud_messaging_wrapper.dart';
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>.value(
      value: _appModel,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          return OverlaySupport(
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              // builder: (context, child) => MediaQuery(
              //   child: child!,
              //   data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              // ),
              home: FeedScreen(),
              onGenerateRoute: (settings) =>
                  AppRouter.onGenerateRoute(settings),
             
              theme: new ThemeData(
                primaryColor: AppColor.brownColor,
              ),
            ),
          );
        },
      ),
    );
  }
}
