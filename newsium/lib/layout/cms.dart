import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:newsium/layout/news/news_page.dart';
import 'package:newsium/utils/app_image.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CMS extends StatefulWidget {
  final CmsType? type;
  const CMS({Key? key, this.type}) : super(key: key);

  @override
  _CMSState createState() => _CMSState();
}

class _CMSState extends State<CMS> {
  @override
  void initState() {
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  WebViewController? _controller;

  String get title => widget.type! == CmsType.Policy
      ? 'Privacy Policy'
      : 'Terms and Conditions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        elevation: 0,
        leading:
            IconButton(icon: Icon(Icons.close), onPressed: () => Get.back()),
      ),
      body: WebView(
        initialUrl: 'about:blank',
        onWebViewCreated: (controller) {
          _controller = controller;
          _loadHtmlFromAssets(type: widget.type!);
        },
      ),
    );
  }

  _loadHtmlFromAssets({CmsType? type}) async {
    String filePath =
        type == CmsType.Policy ? AppFiles.privacyPolicy : AppFiles.tnc;

    String fileText = await rootBundle.loadString(filePath);
    _controller?.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
