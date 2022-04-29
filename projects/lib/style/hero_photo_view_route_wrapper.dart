import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class HeroPhotoViewRouteWrapper extends StatelessWidget {
  const HeroPhotoViewRouteWrapper(
      {required this.imageProvider,
      this.backgroundDecoration,
      this.minScale,
      this.maxScale,
      Key? key})
      : super(key: key);

  final ImageProvider imageProvider;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          constraints: BoxConstraints.expand(
            height: MediaQuery.of(context).size.height,
          ),
          child: Stack(
            children: [
              PhotoView(
                imageProvider: imageProvider,
                backgroundDecoration: backgroundDecoration,
                minScale: minScale,
                maxScale: maxScale,
                heroAttributes: const PhotoViewHeroAttributes(tag: "photoView"),
              ),
              SafeArea(
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
            ],
          )),
    );
  }
}
