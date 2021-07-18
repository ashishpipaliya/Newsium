import 'package:flutter/material.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/app_image.dart';
import 'package:newsium/utils/enum.dart';

class NotificationView extends StatelessWidget {
  final String title;
  final String subTitle;
  final NotificationOViewCallback? onTap;

  NotificationView({this.title = "", this.subTitle = "", this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: GestureDetector(
          child: Container(
            color: Colors.transparent,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    top: 15,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            child: Image.asset(
                              AppImage.menu,
                              width: 20,
                              height: 20,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Text(
                            'Newsium',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppColor.darkTextColor,
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 6)),
                      Text(
                        this.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColor.darkTextColor,
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 6)),
                      Text(
                        this.subTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: AppColor.darkTextColor,
                        ),
                        maxLines: 3,
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                    ],
                  ),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
            ),
          ),
          onTap: () {
            if (this.onTap != null) {
              this.onTap!(true);
            }
          },
        ),
        bottom: false,
      ),
    );
  }
}
