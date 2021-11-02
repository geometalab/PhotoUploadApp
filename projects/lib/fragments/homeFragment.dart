import 'dart:core';
import 'package:button_navigation_bar/button_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:projects/api/pictureOfTheDayService.dart';
import 'package:projects/fragments/articles/uploadGuideFragment.dart';
import 'package:projects/fragments/mapViewFragment.dart';
import 'package:projects/fragments/uploadFlow/selectImage.dart';
import 'package:projects/style/textStyles.dart' as customStyles;
import 'package:projects/style/themes.dart';

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
        onTap: new UploadGuideFragment()));
    articleList.add(new Article(
        title: "Picture of the day",
        description: 'yuh',
        image: FutureBuilder(
          future: PictureOfTheDayService().getPictureOfTheDay(),
          builder:
              (BuildContext context, AsyncSnapshot<PictureOfTheDay> snapshot) {
            if (snapshot.hasData) {
              String link =
                  PictureOfTheDayService().getImageUrl(snapshot.data!);
              return Image.network(link);
            } else {
              return CircularProgressIndicator.adaptive();
            }
          },
        )));
    articleList.add(new Article(
        title: "title 3",
        description: "desciription sadjf sadf",
        image: Image.network(
            "https://www.brownweinraub.com/wp-content/uploads/2017/09/placeholder.jpg")));
    articleList.add(
        new Article(title: "title 4", description: "desciription sadjf sadf"));

    // ------------------------------

    return new Scaffold(
        body: Center(
            child: Column(
          children: [
            Expanded(
                child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                children: articleList.generateLists(
                    context, articleList.generateCards(context)),
              ),
            )),
          ],
        )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: ButtonNavigationBar(
          children: [
            ButtonNavigationItem(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StatefulMapFragment()));
              },
              icon: Icon(Icons.map_outlined),
            ),
            ButtonNavigationItem(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SelectImageFragment()),
                  );
                },
                width: 155,
                label: "Upload Media",
                icon: Icon(Icons.add)),
            ButtonNavigationItem(
                onPressed: () {
                  // TODO Implement search
                },
                icon: Icon(Icons.search))
          ],
        ));
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
      print("No articles to be displayed");
      articles.add(Article(
          title: "No articles", description: "add a article to be displayed"));
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Text(
                        article.description,
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
          child: ListView(
        padding: EdgeInsets.all(2),
        children: list as List<Widget>,
      )));
    }
    return returnList;
  }
}

class Article {
  String title;
  String description;
  Widget? image;
  Widget? onTap;

  Article(
      {required this.title, required this.description, this.image, this.onTap});
}
