import 'package:flutter/material.dart';
import 'package:projects/controller/internal/actionHelper.dart';
import 'package:projects/style/HeroPhotoViewRouteWrapper.dart';
import 'package:projects/style/textStyles.dart' as customStyles;
import 'package:projects/style/unorderedListWidget.dart';

// From https://commons.wikimedia.org/wiki/Commons:First_steps/Uploading_files
// and https://commons.wikimedia.org/wiki/File:Licensing_tutorial_en.svg

class UploadGuideFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Guide"),
      ),
      body: Center(
          child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text("Before you begin:", style: customStyles.headerText),
          Divider(),
          UnorderedList([
            "You need to have the image file you want to upload on your device.",
            "You need an account on Wikipedia or Wikimedia Commons to upload files."
          ], customStyles.articleText),
          Text(
            "What can I upload?",
            style: customStyles.headerText,
          ),
          Divider(),
          Text(
            "Images that you upload to Wikimedia Commons have to be educational and freely licensed. While \"educational\" may be a vague category, \"freely licensed\" is quite specific: ",
            style: customStyles.articleText,
          ),
          Padding(padding: EdgeInsets.only(bottom: 8)),
          UnorderedList([
            "We can accept most images that you create entirely by yourself, so long as your image does not itself depict another copyrighted work.",
            "We can accept images created by others as long as the copyright holder of that image is willing to license/ has already licensed it freely.",
            "We cannot accept images created or inspired by others without their express permission.",
            "We cannot accept any image which is not freely licensed or clearly in the public domain— most images found on the Web are not freely licensed and will be quickly deleted from Commons.",
            "Commons is not a repository for your personal photos – we are not a web hosting service like Facebook or Pinterest, and all of our images must have potential educational use.",
          ], customStyles.articleText),
          Padding(padding: EdgeInsets.only(bottom: 8)),
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
            child: Container(
              child: Hero(
                tag: "someTag",
                child: Image.asset("assets/media/Licensing_tutorial_en.png",
                    width: 350.0),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(bottom: 8)),
          TextButton(
            child: Text("Source"),
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
