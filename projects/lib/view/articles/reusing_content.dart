import 'package:flutter/material.dart';
import 'package:projects/controller/internal/action_helper.dart';
import 'package:projects/style/text_styles.dart' as text_styles;
import 'package:projects/style/unordered_list_widget.dart';

// From https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia

class ReusingContentArticle extends StatelessWidget {
  const ReusingContentArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reusing Media"),
      ),
      body: Center(
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "This page in a nutshell:",
            style: text_styles.headerText,
          ),
          const Divider(),
          const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
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
                  children: const [
                    UnorderedList([
                      "All images on Commons should be reusable but…",
                      "…each may have different requirements for crediting a photographer, linking a license, etc."
                    ], text_styles.articleText),
                  ],
                ),
              )
            ],
          ),
          const Text("Media on Commons", style: text_styles.headerText),
          const Divider(),
          const Text(
            "The Wikimedia Foundation owns almost none of the content on Wikimedia sites — the content is owned, instead, by the individual creators of it. However, almost all content hosted on Wikimedia Commons may be freely reused subject to certain restrictions (in many cases). You do not need to obtain a specific statement of permission from the licensor(s) of the content unless you wish to use the work under different terms than the license states.",
            style: text_styles.articleText,
          ),
          const Text(
            "Content under open content licenses may be reused without any need to contact the licensor(s), but just keep in mind that: ",
            style: text_styles.articleText,
          ),
          const UnorderedList([
            "some licenses require that the original creator be attributed;",
            "some licenses require that the specific license be identified when reusing (including, in some cases, stating or linking to the terms of the license);",
            "some licenses require that if you modify the work, your modifications must also be similarly freely licensed; and finally...",
            "...content in the public domain may not have a strict legal requirement of attribution (depending on the jurisdiction of content reuse), but attribution is recommended to give correct provenance."
          ], text_styles.articleText),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          TextButton(
            child: const Text("Read more"),
            onPressed: () async {
              String url =
                  "https://commons.wikimedia.org/wiki/Commons:Reusing_content_outside_Wikimedia#How_to_comply_with_a_file's_license_requirements";
              ActionHelper().openUrl(url);
            },
          )
        ],
      )),
    );
  }
}
