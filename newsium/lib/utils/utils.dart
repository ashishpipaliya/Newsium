import 'package:flutter/material.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Utils {
  static showNewsInDialog(BuildContext context, {required String? url}) {
    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.85,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(20),
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: new BorderRadius.all(const Radius.circular(25.0)),
            ),
            child: WebView(
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
          Positioned(
            right: 15,
            top: 10,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColor.darkTextColor),
                child: Icon(
                  Icons.close,
                  color: AppColor.whiteColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static showNewsBottomSheet(BuildContext context, {required News? news}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(15),
                )),
            child: Column(
              children: [
                Image.network(
                  news!.imageUrl!,
                  width: double.infinity,
                  height: 210,
                  fit: BoxFit.cover,
                ),
                Text(
                  news.title!,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                ),
                Text(
                  news.description!,
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16),
                ),
              ],
            ));
      },
    );
  }
}
