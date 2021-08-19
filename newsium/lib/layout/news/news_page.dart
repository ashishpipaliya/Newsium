import 'package:flutter/material.dart';
import 'package:newsium/layout/news/tabbed_news_page_pagination.dart';
import 'package:newsium/models/news_model.dart';
import 'package:newsium/utils/app_image.dart';

class CategoryWiseNewsPage extends StatefulWidget {
  final int? tabIndex;

  const CategoryWiseNewsPage({Key? key, this.tabIndex}) : super(key: key);

  @override
  _CategoryWiseNewsPageState createState() => _CategoryWiseNewsPageState();
}

class _CategoryWiseNewsPageState extends State<CategoryWiseNewsPage>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    _controller = TabController(
        length: categories.length,
        initialIndex: widget.tabIndex ?? 0,
        vsync: this);
    _controller?.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        size: 30,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                        ;
                      },
                    ),
                    IconButton(
                      onPressed: _handleMenuClickEvent,
                      icon: Image.asset(
                        AppImage.menu,
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabBar(
              indicatorPadding: EdgeInsets.zero,
              isScrollable: true,
              controller: _controller,
              indicator: BoxDecoration(),
              tabs: categories
                  .map(
                    (e) => _customTab(
                      e,
                      categories.indexOf(e),
                    ),
                  )
                  .toList(),
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                physics: NeverScrollableScrollPhysics(),
                children: categories
                    .map(
                      (e) => TabbedNewsPagePaginated(category: e),
                    )
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _customTab(String title, int index) {
    bool isSelected = index == _controller?.index;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title.replaceAll('_', ' '),
              style: TextStyle(
                color: isSelected ? Colors.brown : Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 8),
              alignment: Alignment.centerLeft,
              width: 35,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.brown : Colors.transparent,
                    width: 3,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ]),
    );
  }

  _handleMenuClickEvent() {}
}
