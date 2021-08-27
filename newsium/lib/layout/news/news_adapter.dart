import 'dart:math';

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
        border: Border.all(color: Colors.black38),
        gradient: LinearGradient(
          colors: [
            Colors.primaries[Random().nextInt(Colors.primaries.length)]
                .withOpacity(0.1),
            Colors.accents[Random().nextInt(Colors.accents.length)]
                .withOpacity(0.1),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: openWeb,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                  child: Text(
                news!.title!,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              )),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 230),
                child: ImageWidget(
                  url: news?.imageUrl,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(news!.sourceName!), Text(news!.createdAtAgo)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
