import 'package:flutter/material.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/widgets/image_widget.dart';

class RectangleNewsAdapter extends StatelessWidget {
  final News? news;
  final Function()? openModal;
  final Function()? openWeb;
  final Function()? viewImage;
  const RectangleNewsAdapter(
      {Key? key, this.news, this.openWeb, this.openModal, this.viewImage})
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          GestureDetector(
            onTap: viewImage,
            child: Container(
              height: 90,
              width: 90,
              child: ImageWidget(
                url: news!.imageUrl!,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: GestureDetector(
              onTap: openModal,
              onDoubleTap: openWeb,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        news!.title!.trim(),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
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
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
