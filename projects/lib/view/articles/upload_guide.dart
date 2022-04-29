import 'package:flutter/material.dart';
import 'package:projects/controller/internal/action_helper.dart';
import 'package:projects/style/hero_photo_view_route_wrapper.dart';
import 'package:projects/style/text_styles.dart' as text_styles;
import 'package:projects/style/unordered_list_widget.dart';

// From https://commons.wikimedia.org/wiki/Commons:First_steps/Uploading_files
// and https://commons.wikimedia.org/wiki/File:Licensing_tutorial_en.svg

class UploadGuideArticle extends StatelessWidget {
  const UploadGuideArticle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Guide"),
      ),
      body: Center(
          child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text("Before you begin:", style: text_styles.headerText),
          const Divider(),
          const UnorderedList([
            "You need to have the image file you want to upload on your device.",
            "You need an account on Wikipedia or Wikimedia Commons to upload files."
          ], text_styles.articleText),
          const Text(
            "What can I upload?",
            style: text_styles.headerText,
          ),
          const Divider(),
          const Text(
            "Images that you upload to Wikimedia Commons have to be educational and freely licensed. While \"educational\" may be a vague category, \"freely licensed\" is quite specific: ",
            style: text_styles.articleText,
          ),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          const UnorderedList([
            "We can accept most images that you create entirely by yourself, so long as your image does not itself depict another copyrighted work.",
            "We can accept images created by others as long as the copyright holder of that image is willing to license/ has already licensed it freely.",
            "We cannot accept images created or inspired by others without their express permission.",
            "We cannot accept any image which is not freely licensed or clearly in the public domain— most images found on the Web are not freely licensed and will be quickly deleted from Commons.",
            "Commons is not a repository for your personal photos – we are not a web hosting service like Facebook or Pinterest, and all of our images must have potential educational use.",
          ], text_styles.articleText),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeroPhotoViewRouteWrapper(
                    imageProvider: AssetImage(
                      "assets/media/Licensing_tutorial_en.png",
                    ),
                  ),
                ),
              );
            },
            child: Hero(
              tag: "someTag",
              child: Image.asset("assets/media/Licensing_tutorial_en.png",
                  width: 350.0),
            ),
          ),
          const Padding(padding: EdgeInsets.only(bottom: 8)),
          TextButton(
            child: const Text("Source"),
            onPressed: () async {
              String url =
                  "https://commons.wikimedia.org/wiki/Commons:First_steps/Uploading_files";
              ActionHelper().launchUrl(url);
            },
          )
        ],
      )),
    );
  }
}
