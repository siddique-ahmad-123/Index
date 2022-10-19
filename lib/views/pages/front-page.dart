import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:index/models/articles-model.dart';
import 'package:index/widgets/article-category-separator.dart';
import 'package:index/widgets/article.dart';
import 'package:index/widgets/error.dart';
import 'package:index/widgets/frontpage-header.dart';
import 'package:index/widgets/shimmer.dart';
import 'package:index/widgets/url.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../models/article-model.dart';
import '../../services/article-service.dart';
import 'article-page.dart';

class FrontPage extends StatefulWidget {
  @override
  _FrontPageState createState() => _FrontPageState();
}

class _FrontPageState extends State<FrontPage> {
  Future<ArticlesModel>? futureArticles;
  int dragCount = 0;

  @override
  void initState() {
    super.initState();
    final service = ArticleService();
    futureArticles = service.fetchFrontPage();
  }

  Widget _buildArticle(ArticleModel article) {
    return ListTile(
      contentPadding: EdgeInsets.fromLTRB(24, 8, 24, 8),
      title: Text(
        article.title!,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Container(
        margin: EdgeInsets.only(top: 8),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Container(
                  child: getArticleScoreStylizedText(context, article.score!),
                  margin: EdgeInsets.only(right: 8)),
              Container(
                  child: Text(timeago.format(article.time!),
                      style: Theme.of(context).textTheme.subtitle2),
                  margin: EdgeInsets.only(right: 8)),
              getReadableUrlWidget(context, article.url ?? ''),
            ]),
      ),
      trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.message_outlined),
            Text(article.descendants.toString())
          ]),
      onTap: () => Get.to(ArticlePage(article: article)),
    );
  }

  Widget _buildArticlesList() {
    return FutureBuilder(
      future: futureArticles,
      builder: (context, AsyncSnapshot<ArticlesModel> snapshot) {
        // Detemine whether to render the loading/error state or the list
        final int childCount =
            snapshot.hasData ? snapshot.data!.articles!.length : 1;

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) {
              if (snapshot.hasError) {
                return getGenericErrorWidget(context);
              }
              if (snapshot.connectionState != ConnectionState.done ||
                  snapshot.hasData == false) {
                return Padding(
                  padding: EdgeInsets.only(left: 24, right: 24),
                  child: Column(
                    children: [
                      const ShimmerText(
                          height: 25, width: 150, marginBottom: 24),
                      const ShimmerArticle(),
                      const ShimmerArticle(),
                      const ShimmerArticle(),
                      const ShimmerArticle(),
                      const ShimmerArticle(),
                      const ShimmerArticle(),
                    ],
                  ),
                );
              }

              final List<Widget> childrenToRender = [
                _buildArticle(snapshot.data!.articles![i]),
              ];

              // TODO: Add different categories
              if (i == 0) {
                childrenToRender.insert(
                    0,
                    ArticleCategorySeparator(
                        title: 'THE FRONTPAGE.', showSeparator: false));
              }

              if (i == 5) {
                childrenToRender.insert(
                    0, ArticleCategorySeparator(title: 'AROUND THE WEB.'));
              }

              return Column(children: [...childrenToRender]);
            },
            childCount: childCount,
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    if (dragCount == 0) {
      DateTime currentTime = DateTime.now();
      // 7 AM
      DateTime startTime =
          DateTime(currentTime.year, currentTime.month, currentTime.day, 7)
              .add(Duration(days: 1));
      Duration diff = startTime.difference(currentTime);
      await Fluttertoast.showToast(
        msg:
            "Time until next edition: ${diff.inHours} hrs ${diff.inMinutes - (diff.inHours * 60)} min",
      );
      await Fluttertoast.showToast(msg: "Drag again to force refresh");
      setState(() {
        dragCount += 1;
      });
    } else {
      await Fluttertoast.showToast(msg: "Refreshing feed");

      setState(() {
        dragCount = 0;
        futureArticles = ArticleService().fetchFrontPage(forceRefresh: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        slivers: [
          FrontPageHeader(articles: futureArticles),
          // SliverPadding(padding: EdgeInsets.all(5)),
          _buildArticlesList()
        ],
      ),
    ));
  }
}
