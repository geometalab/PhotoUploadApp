import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:projects/style/textStyles.dart' as customStyles;

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
              "You need to have the image file you want to upload on your computer.",
              "You need an account on Wikipedia or Wikimedia Commons to upload files."]),
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
                  child: Image.asset(
                      "assets/media/Licensing_tutorial_en.png",
                      width: 350.0
                  ),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.only(bottom: 8)),
            Text("Source: https://commons.wikimedia.org/wiki/Commons:First_steps/Uploading_files"),
          ],
        )
      ),
    );

  }

}

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper({
    required this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
  });

  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.expand(
        height: MediaQuery.of(context).size.height,
      ),
      child: PhotoView(
        imageProvider: imageProvider,
        backgroundDecoration: backgroundDecoration,
        minScale: minScale,
        maxScale: maxScale,
        heroAttributes: const PhotoViewHeroAttributes(tag: "someTag"),
      ),
    );
  }
}

class UnorderedList extends StatelessWidget {
  UnorderedList(this.texts);
  final List<String> texts;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(text));
      // Add space between items
      widgetList.add(SizedBox(height: 5.0));
    }

    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  UnorderedListItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("• "),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}