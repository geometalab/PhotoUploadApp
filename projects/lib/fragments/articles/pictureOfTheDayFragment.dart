import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/api/pictureOfTheDayService.dart';
import 'package:projects/style/HeroPhotoViewRouteWrapper.dart';
import 'package:projects/style/textStyles.dart';

class PictureOfTheDayFragment extends StatelessWidget {
  PictureOfTheDayService potd = PictureOfTheDayService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Picture of the day"),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Text(
              "Wikimedia Picture of the day",
              style: headerText,
            ),
            Divider(),
            imageBuilder(),
          ],
        ),
      ),
    );
  }

  FutureBuilder imageBuilder() {
    return FutureBuilder(
      future: potd.getPictureOfTheDay(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HeroPhotoViewRouteWrapper(
                          imageProvider: NetworkImage(
                              potd.getImageUrl(snapshot.data, 900)),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    child: Hero(
                      tag: "someTag",
                      child:
                          Image.network(potd.getImageUrl(snapshot.data, 900)),
                    ),
                  )),
              RichText(
                text:
                    TextSpan(children: potd.getImageDescription(snapshot.data)),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }
}
