import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

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