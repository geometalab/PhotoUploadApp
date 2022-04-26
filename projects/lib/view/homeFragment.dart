import 'dart:core';
import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/pictureOfTheDayService.dart';
import 'package:projects/view/articles/licenseGuide.dart';
import 'package:projects/view/articles/pictureOfTheDay.dart';
import 'package:projects/view/articles/reusingContent.dart';
import 'package:projects/view/articles/uploadGuide.dart';
import 'package:projects/style/textStyles.dart' as customStyles;

class HomeFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var articleList = new ArticleList();
    articleList.clear();

    // ----- Add Articles below -----

    articleList.add(new Article(
        title: "Upload Guide",
        description:
            "This short guide gives an overview over what you can upload to Wikimedia Commons.",
        onTap: UploadGuideArticle()));
    articleList.add(new Article(
        title: "Reusing Wikimedia content",
        description:
            "If you wish to reuse content from Wikimedia Commons - on your own website, in print, or otherwise - check out this article.",
        onTap: ReusingContentArticle()));
    articleList.add(new Article(
        title: "License Guide",
        image: Image.network(
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/CC-BY-SA_icon.svg/640px-CC-BY-SA_icon.svg.png"),
        description:
            "This page gives non-lawyers an overview of complicated copyright laws.",
        onTap: LicenseGuideArticle()));

    // ------------------------------

    Widget headerWidget() {
      return Card(
          color: Theme.of(context).cardColor,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PictureOfTheDayArticle()),
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
                            padding: EdgeInsets.fromLTRB(12, 48, 12, 12),
                            child: Text(
                              "Picture of the Day",
                              style: customStyles.articleTitle
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                } else {
                  child = Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                return AnimatedSwitcher(
                  duration: Duration(milliseconds: 1000),
                  child: child,
                );
              },
            ),
          ));
    }

    return new Scaffold(
      body: Center(
          child: ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(8),
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
  static List<Article> articles = new List.empty(growable: true);

  add(Article article) {
    articles.add(article);
  }

  clear() {
    articles.clear();
  }

  List<Card> generateCards(BuildContext context) {
    List<Card> cards = new List.empty(growable: true);
    List<Article> articles = ArticleList.articles;

    if (articles.length == 0) {
      throw ("No articles to be displayed");
    }

    for (Article article in articles) {
      cards.add(new Card(
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
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          article.title,
                          style: customStyles.articleTitle,
                        )),
                    if (article.image != null)
                      Padding(
                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                          child: article.image as Widget),
                    if (article.description != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                        child: Text(
                          article.description ?? "",
                          style: customStyles.objectDescription,
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
    List<Expanded> returnList = new List.empty(growable: true);
    List<Card> cardList1 = new List.empty(growable: true);
    List<Card> cardList2 = new List.empty(growable: true);
    for (int i = 0; i < cards.length; i = i + 2) {
      cardList1.add(cards[i]);
      if (i + 1 < cards.length) {
        cardList2.add(cards[i + 1]);
      }
    }
    List<List<Card>> listception = new List.empty(growable: true);
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
