import 'package:flutter/material.dart';
import 'package:projects/controller/internal/actionHelper.dart';
import 'package:projects/style/textStyles.dart' as customStyles;
import 'package:projects/style/unorderedListWidget.dart';

// From https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia

class ReusingContentArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reusing Media"),
      ),
      body: Center(
          child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text(
            "This page in a nutshell:",
            style: customStyles.headerText,
          ),
          Divider(),
          Padding(padding: EdgeInsets.symmetric(vertical: 4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.emoji_objects,
                  color: Theme.of(context).colorScheme.primary,
                  size: 40,
                ),
              ),
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UnorderedList([
                      "All images on Commons should be reusable but…",
                      "…each may have different requirements for crediting a photographer, linking a license, etc."
                    ], customStyles.articleText),
                  ],
                ),
              )
            ],
          ),
          Text("Media on Commons", style: customStyles.headerText),
          Divider(),
          Text(
            "The Wikimedia Foundation owns almost none of the content on Wikimedia sites — the content is owned, instead, by the individual creators of it. However, almost all content hosted on Wikimedia Commons may be freely reused subject to certain restrictions (in many cases). You do not need to obtain a specific statement of permission from the licensor(s) of the content unless you wish to use the work under different terms than the license states.",
            style: customStyles.articleText,
          ),
          Text(
            "Content under open content licenses may be reused without any need to contact the licensor(s), but just keep in mind that: ",
            style: customStyles.articleText,
          ),
          UnorderedList([
            "some licenses require that the original creator be attributed;",
            "some licenses require that the specific license be identified when reusing (including, in some cases, stating or linking to the terms of the license);",
            "some licenses require that if you modify the work, your modifications must also be similarly freely licensed; and finally...",
            "...content in the public domain may not have a strict legal requirement of attribution (depending on the jurisdiction of content reuse), but attribution is recommended to give correct provenance."
          ], customStyles.articleText),
          Padding(padding: EdgeInsets.only(bottom: 8)),
          TextButton(
            child: Text("Read more"),
            onPressed: () async {
              String url =
                  "https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia#How_to_comply_with_a_file's_license_requirements";
              ActionHelper().launchUrl(url);
            },
          )
        ],
      )),
    );
  }
}
