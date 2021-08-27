import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:newsium/layout/news/rectangle_news_adapter.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/services/firestore_path.dart';
import 'package:newsium/utils/app_color.dart';
import 'package:newsium/utils/utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:photo_view/photo_view.dart';

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
            openModal: () => _showNewsInModal(context, news: n),
            viewImage: () => _viewImage(n.imageUrl!),
          );
        },
        query: FirestorePath.categoryWiseQuery(category: widget.category),
        itemBuilderType: PaginateBuilderType.listView,
        shrinkWrap: true,
        emptyDisplay: Center(child: Text('No Records Found')),
        itemsPerPage: 10,
        initialLoader: SpinKitThreeBounce(color: AppColor.brownColor, size: 20),
        bottomLoader: SpinKitThreeBounce(color: AppColor.brownColor, size: 20),
        isLive: false,
      ),
    );
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

  _viewImage(String? image) {
    Get.to(() => ViewImage(image: image), transition: Transition.fadeIn);
  }
}

class ViewImage extends StatelessWidget {
  final String? image;
  const ViewImage({Key? key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: NetworkImage(image!));
  }
}
