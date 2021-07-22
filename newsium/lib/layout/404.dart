import 'package:flutter/material.dart';
import 'package:newsium/utils/app_image.dart';

class ErrorPage extends StatelessWidget {
  const ErrorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Image.asset(AppImage.pageNotFound),
        ),
      ),
    );
  }
}
