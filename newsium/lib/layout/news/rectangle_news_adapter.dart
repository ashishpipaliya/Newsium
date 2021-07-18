import 'package:flutter/material.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/app_image.dart';
import 'package:newsium/utils/widgets/image_widget.dart';

class RectangleNewsAdapter extends StatelessWidget {
  final News? news;
  final Function()? openWeb;
  const RectangleNewsAdapter({Key? key, this.news, this.openWeb})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      constraints: BoxConstraints(maxHeight: 130),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColor.tileBackgroundGrayColor,
      ),
      child: Material(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Container(
              height: 90,
              width: 90,
              child: ImageWidget(
                url: news!.imageUrl!,
                placeholder: AppImage.placeholder,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            SizedBox(width: 10),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: openWeb,
                      child: Text(
                        news!.title!,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          news!.createdAtAgo,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          news!.sourceName!,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w100,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
