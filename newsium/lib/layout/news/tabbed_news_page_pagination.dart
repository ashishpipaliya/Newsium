import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newsium/layout/news/rectangle_news_adapter.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/services/firestore_path.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class TabbedNewsPagePaginated extends StatefulWidget {
  final List<News>? news;
  final String? category;
  final int? limit;
  const TabbedNewsPagePaginated(
      {Key? key, this.news, this.category, this.limit})
      : super(key: key);

  @override
  _TabbedNewsPagePaginatedState createState() =>
      _TabbedNewsPagePaginatedState();
}

class _TabbedNewsPagePaginatedState extends State<TabbedNewsPagePaginated> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColor.whiteColor,
      ),
      child: PaginateFirestore(
        physics: ClampingScrollPhysics(),
        itemBuilder: (index, context, documentSnapshot) {
          final data = documentSnapshot.data() as Map<String, dynamic>?;
          News n = News.fromJson(data);
          return RectangleNewsAdapter(
            news: n,
            openWeb: () => _showNewsInBottomSheet(context, url: n.sourceUrl),
          );
        },
        query: FirestorePath.categoryWiseQuery(category: widget.category),
        itemBuilderType: PaginateBuilderType.listView,
        shrinkWrap: true,
        itemsPerPage: 10,
        initialLoader: SpinKitThreeBounce(color: AppColor.brownColor, size: 20),
        bottomLoader: SpinKitThreeBounce(color: AppColor.brownColor, size: 20),
        isLive: true,
      ),
    );
  }

  _showNewsInBottomSheet(BuildContext context, {required String? url}) {
    Utils.showNewsInBottomSheet(context, url: url);
  }
}
