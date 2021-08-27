import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:newsium/models/news_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Utils {
  static showNewsWebview(BuildContext context, {required String? url}) {
    UniqueKey _key = UniqueKey();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: .8,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(10),
          decoration: new BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.all(const Radius.circular(25.0)),
          ),
          child: WebView(
            key: _key,
            gestureRecognizers: [
              Factory(() => VerticalDragGestureRecognizer()),
            ].toSet(),
            gestureNavigationEnabled: true,
            debuggingEnabled: false,
            initialUrl: url,
            allowsInlineMediaPlayback: true,
            javascriptMode: JavascriptMode.unrestricted,
            onWebResourceError: (error) {
              Center(
                child: Text('''
                  Unable to load website ${error.domain} due to error ${error.errorType} 
                  '''),
              );
            },
          ),
        ),
      ),
    );
  }

  static showNewsBottomSheet(BuildContext context,
      {required News? news, required void Function()? readMore}) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.52,
          maxChildSize: 0.52,
          builder: (context, scrollController) => Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  )),
              child: ListView(
                controller: scrollController,
                children: [
                  GestureDetector(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        news!.imageUrl!,
                        width: double.infinity,
                        height: 210,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    news.title!,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                  Text(
                    news.description!,
                    style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                  ),
                  TextButton(onPressed: readMore, child: Text("Read More"))
                ],
              )),
        );
      },
    );
  }
}
