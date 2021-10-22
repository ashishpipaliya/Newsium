import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:newsium/layout/news/news_adapter.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/services/firestore_path.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/app_image.dart';
import 'package:newsium/utils/utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  PageController? _feedController;
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _feedController?.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _feedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 15),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 0,
                        children: [
                          Image.asset(
                            AppImage.logo,
                            width: 25,
                            height: 25,
                            alignment: Alignment.bottomCenter,
                            fit: BoxFit.fitHeight,
                          ),
                          Text('ewsium',
                              style: TextStyle(
                                  fontSize: 22,
                                  color: AppColor.darkTextColor,
                                  fontWeight: FontWeight.bold)),
                        ],
                      )),
                ],
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.5,
                child: PaginateFirestore(
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (index, context, documentSnapshot) {
                    final data =
                        documentSnapshot.data() as Map<String, dynamic>?;
                    News n = News.fromJson(data);
                    return NewsAdapter(
                      news: n,
                      openWeb: () => _showNewsInModal(context, news: n),
                    );
                  },
                  query: FirestorePath.allNews,
                  itemBuilderType: PaginateBuilderType.pageView,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  emptyDisplay: Center(child: Text('No Latest News Found')),
                  initialLoader:
                      SpinKitThreeBounce(color: AppColor.brownColor, size: 20),
                  bottomLoader:
                      SpinKitThreeBounce(color: AppColor.brownColor, size: 20),
                  isLive: true,
                  itemsPerPage: 5,
                ),
              ),
              Flexible(
                child: Container(
                  child: GridView.builder(
                    itemCount: categories.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                    ),
                    itemBuilder: (context, index) {
                      return CategoryAdapter(
                        onTap: () => _handleCategoryPushEvent(index),
                        categoryName: categories[index],
                        index: index,
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }

  _showNewsInModal(BuildContext context, {required News? news}) {
    Utils.showNewsBottomSheet(
      context,
      news: news,
      readMore: () {
        Get.back();
        Utils.showNewsWebview(context, url: news!.sourceUrl);
      },
    );
  }

  _handleCategoryPushEvent(int index) {
    Get.toNamed('/CategoryWiseNewsPage', arguments: index);
  }
}

class CategoryAdapter extends StatelessWidget {
  final String? categoryName;
  final int? index;
  final void Function()? onTap;

  const CategoryAdapter({Key? key, this.categoryName, this.index, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black38),
          gradient: LinearGradient(
            colors: [
              Colors.primaries[Random().nextInt(Colors.primaries.length)]
                  .withOpacity(0.3),
              Colors.accents[Random().nextInt(Colors.accents.length)]
                  .withOpacity(0.4),
            ],
          ),
        ),
        child: Text(
          categoryName!.replaceAll('_', ' '),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
