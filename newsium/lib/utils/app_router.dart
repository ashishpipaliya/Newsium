import 'package:flutter/material.dart';
import 'package:newsium/layout/404.dart';
import 'package:newsium/layout/feed_page.dart';
import 'package:newsium/layout/news/news_page.dart';

class AppRoutes {
  static const feedScreen = '/FeedScreen';
  static const categoryWiseNewsPage = '/CategoryWiseNewsPage';
  static const error = '/error';
}

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.feedScreen:
        return MaterialPageRoute<dynamic>(
          builder: (_) => FeedScreen(),
          settings: settings,
        );
      case AppRoutes.categoryWiseNewsPage:
        final tabIndex = args as int?;
        return MaterialPageRoute<dynamic>(
          builder: (_) => CategoryWiseNewsPage(tabIndex: tabIndex),
          settings: settings,
        );
      default:
        return MaterialPageRoute<dynamic>(
          builder: (_) => ErrorPage(),
          settings: settings,
          fullscreenDialog: true,
        );
    }
  }
}
