import 'package:flutter/material.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/widgets/image_widget.dart';

class NewsAdapter extends StatelessWidget {
  final News? news;
  final Function()? openWeb;
  const NewsAdapter({Key? key, this.news, this.openWeb}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: kElevationToShadow[1],
        color: AppColor.cardBackgroundColor,
      ),
      child: Material(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
                child: InkWell(
              onTap: openWeb,
              child: Text(
                news!.title!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              ),
            )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 220),
                child: ImageWidget(
                  url: news!.imageUrl,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(news!.sourceName!), Text(news!.createdAtAgo)],
            ),
          ],
        ),
      ),
    );
  }
}