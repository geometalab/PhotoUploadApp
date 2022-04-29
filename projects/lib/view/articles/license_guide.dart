import 'package:flutter/material.dart';
import 'package:projects/controller/internal/action_helper.dart';
import 'package:projects/style/text_styles.dart' as text_styles;
import 'package:projects/style/unordered_list_widget.dart';

class LicenseGuideArticle extends StatelessWidget {
  const LicenseGuideArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("License Guide"),
      ),
      body: Center(
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Acceptable licenses", style: text_styles.headerText),
          const Divider(),
          const Text(
            "A copyright license is a formal permission stating who may use a copyrighted work and how they may use it. A license can only be granted by the copyright holder, which is usually the author (photographer, painter or similar). ",
            style: text_styles.articleText,
          ),
          const Text(
            'All copyrighted material on Commons (not in the public domain) must be licensed under a free license that specifically and irrevocably allows anyone to use the material for any purpose; simply writing that "the material may be used freely by anyone" or similar is not sufficient. In particular, the license must meet the following conditions: ',
            style: text_styles.articleText,
          ),
          const UnorderedList([
            "Republication and distribution must be allowed.",
            "Publication of derivative work must be allowed.",
            "Commercial use of the work must be allowed.",
            "The license must be perpetual (non-expiring) and non-revocable.",
            "Acknowledgment of all authors/contributors of a work may be required.",
            "Publication of derivative work under the same license may be required.",
            "For digital distribution, use of open file formats free of digital restrictions management (DRM) may be required."
          ], text_styles.articleText),
          const Text("Licenses supported by Commons Uploader",
              style: text_styles.headerText),
          const Divider(),
          const Text(
            "In Commons Uploader, you can select one of the five most commonly used licenses for uploading Media to Wikimedia Commons. These include: ",
            style: text_styles.articleText,
          ),
          const UnorderedList([
            "CC0",
            "Attribution 3.0",
            "Attribution-ShareAlike 3.0",
            "Attribution 4.0",
            "Attribution-ShareAlike 4.0",
          ], text_styles.articleText),
          const Text(
            "The main similarity between all these licenses is that they allow others distribute, remix, adapt, and build upon your work, even commercially, as long as they credit you for the original creation. The only exception to this is the CCO license, where the author does not need to be credited.",
            style: text_styles.articleText,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          TextButton(
            child: const Text("Read more"),
            onPressed: () async {
              String url =
                  "https://commons.wikimedia.org/wiki/Commons:Licensing";
              ActionHelper().launchUrl(url);
            },
          )
        ],
      )),
    );
  }
}
