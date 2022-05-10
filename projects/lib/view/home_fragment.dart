import 'dart:core';
import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/picture_of_the_day_service.dart';
import 'package:projects/view/articles/license_guide.dart';
import 'package:projects/view/articles/other_wikimedia_projects.dart';
import 'package:projects/view/articles/picture_of_the_day.dart';
import 'package:projects/view/articles/reusing_content.dart';
import 'package:projects/view/articles/upload_guide.dart';
import 'package:projects/style/text_styles.dart' as text_styles;

class HomeFragment extends StatelessWidget {
  const HomeFragment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ----- Add Articles below -----
    ArticleList articleList = ArticleList();
    articleList.setArticles([
      Article(
          title: "Upload Guide",
          description:
              "This short guide gives an overview over what you can upload to Wikimedia Commons.",
          onTap: const UploadGuideArticle()),
      Article(
          title: "Reusing Wikimedia content",
          description:
              "If you wish to reuse content from Wikimedia Commons - on your own website, in print, or otherwise - check out this article.",
          onTap: const ReusingContentArticle()),
      Article(
          title: "License Guide",
          image: Image.asset("assets/media/CC_BY-SA_icon.png"),
          description:
              "This page gives non-lawyers an overview of complicated copyright laws.",
          onTap: const LicenseGuideArticle()),
      Article(
          title: "Other Wikimedia Projects",
          description:
              "Wikimedia Commons is part of the non-profit, multilingual, free-content Wikimedia family.",
          onTap: const OtherWikimediaProjectsArticle()),
    ]);

    // ------------------------------

    Widget headerWidget() {
      return Card(
          color: Theme.of(context).cardColor,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PictureOfTheDayArticle()),
              );
            },
            child: FutureBuilder(
              future: PictureOfTheDayService().getPictureOfTheDayAsync(),
              builder: (BuildContext context,
                  AsyncSnapshot<PictureOfTheDay> snapshot) {
                Widget child;
                double borderRadius = 4.0;
                if (snapshot.hasData) {
                  child = Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(borderRadius),
                        child: Image.network(snapshot.data!.imageUrl),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(borderRadius),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.black12.withOpacity(0.8),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 48, 12, 12),
                            child: Text(
                              "Picture of the Day",
                              style: text_styles.articleTitle
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  child = const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 1000),
                  child: child,
                );
              },
            ),
          ));
    }

    return Scaffold(
      body: Center(
          child: ListView(
        scrollDirection: Axis.vertical,
        padding: const EdgeInsets.all(8),
        children: [
          headerWidget(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: articleList.generateLists(
                context, articleList.generateCards(context)),
          ),
        ],
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ArticleList {
  static List<Article> articles = List.empty(growable: true);

  setArticles(List<Article> newArticles) {
    articles = newArticles;
  }

  add(Article article) {
    articles.add(article);
  }

  clear() {
    articles.clear();
  }

  List<Card> generateCards(BuildContext context) {
    List<Card> cards = List.empty(growable: true);
    List<Article> articles = ArticleList.articles;

    if (articles.isEmpty) {
      throw ("No articles to be displayed");
    }

    for (Article article in articles) {
      cards.add(Card(
          color: Theme.of(context).cardColor,
          child: GestureDetector(
              onTap: () {
                if (article.onTap != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => article.onTap!),
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          article.title,
                          style: text_styles.articleTitle,
                        )),
                    if (article.image != null)
                      Padding(
                          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: article.image as Widget),
                    if (article.description != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Text(
                          article.description ?? "",
                          style: text_styles.objectDescription,
                        ),
                      )
                  ],
                ),
              ))));
    }
    return cards;
  }

  List<Expanded> generateLists(BuildContext context, List<Card> cards) {
    // This is ugly, but at least it isn't redundant
    List<Expanded> returnList = List.empty(growable: true);
    List<Card> cardList1 = List.empty(growable: true);
    List<Card> cardList2 = List.empty(growable: true);
    for (int i = 0; i < cards.length; i = i + 2) {
      cardList1.add(cards[i]);
      if (i + 1 < cards.length) {
        cardList2.add(cards[i + 1]);
      }
    }
    List<List<Card>> listception = List.empty(growable: true);
    listception.add(cardList1);
    listception.add(cardList2);

    for (List list in listception) {
      returnList.add(Expanded(
          child: Column(
        children: list as List<Widget>,
      )));
    }
    return returnList;
  }
}

class Article {
  String title;
  String? description;
  Widget? image;
  Widget? onTap;

  Article({required this.title, this.description, this.image, this.onTap});
}
