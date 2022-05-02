import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/internal/action_helper.dart';
import 'package:projects/style/text_styles.dart' as text_styles;

class OtherWikimediaProjectsArticle extends StatelessWidget {
  const OtherWikimediaProjectsArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Other Wikimedia Projects"),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(8),
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        children: [
          projectCard(
              "Wikipedia",
              "Encyclopedia",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/8/80/Wikipedia-logo-v2.svg/256px-Wikipedia-logo-v2.svg.png",
              "https://wikipedia.org"),
          projectCard(
              "Wikinews",
              "Open journalism",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Wikinews-logo.svg/256px-Wikinews-logo.svg.png",
              "https://wikinews.org"),
          projectCard(
              "Wiktionary",
              "Dictionary & thesaurus",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Wiktionary-logo.svg/256px-Wiktionary-logo.svg.png",
              "https://wiktionary.org"),
          projectCard(
              "Wikibooks",
              "Textbooks & manuals",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikibooks-logo.svg/256px-Wikibooks-logo.svg.png",
              "https://wikibooks.org"),
          projectCard(
              "Wikiquote",
              "Quotations",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Wikiquote-logo.svg/256px-Wikiquote-logo.svg.png",
              "https://wikiquote.org"),
          projectCard(
              "Wikispecies",
              "Species directory",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Wikispecies-logo.svg/256px-Wikispecies-logo.svg.png",
              "https://wikispecies.org"),
          projectCard(
              "Wikiversity",
              "Learning resources",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0b/Wikiversity_logo_2017.svg/256px-Wikiversity_logo_2017.svg.png",
              "https://wikiversity.org"),
          projectCard(
              "Wikivoyage",
              "Travel guide",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Wikivoyage-logo.svg/256px-Wikivoyage-logo.svg.png",
              "https://wikivoyage.org"),
          projectCard(
              "Wikisource",
              "Source Texts",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Wikisource-logo.svg/256px-Wikisource-logo.svg.png",
              "https://wikisource.org"),
          projectCard(
              "Wikidata",
              "Knowledge Base",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/f/ff/Wikidata-logo.svg/256px-Wikidata-logo.svg.png",
              "https://wikidata.org"),
          projectCard(
              "Meta-wiki",
              "Coordination",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/7/75/Wikimedia_Community_Logo.svg/256px-Wikimedia_Community_Logo.svg.png",
              "https://meta.wikimedia.org"),
          projectCard(
              "MediaWiki",
              "Wiki Software development",
              "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/MediaWiki-2020-icon.svg/256px-MediaWiki-2020-icon.svg.png",
              "https://mediawiki.org"),
        ],
      ),
    );
  }

  Widget projectCard(
      String title, String subtitle, String imageUrl, String link) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CachedNetworkImage(imageUrl: imageUrl, height: 64),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Text(
                title,
                style: text_styles.articleTitle,
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: text_styles.hintText,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        ActionHelper().openUrl(link);
      },
    );
  }
}
