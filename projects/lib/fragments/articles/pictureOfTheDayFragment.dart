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
        child: FutureBuilder(
          future: PictureOfTheDayService().getPictureOfTheDayAsync(),
          builder: (BuildContext context, AsyncSnapshot<PictureOfTheDay> snapshot) {
            if(snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.all(16),
                children: [
                  Text(
                    "Wikimedia Picture of the day",
                    style: headerText,
                  ),
                  Divider(),
                  Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HeroPhotoViewRouteWrapper(
                                      imageProvider: NetworkImage(
                                        snapshot.data!.imageUrl,
                                      ),
                                    )
                                ));
                          },
                          child: Container(
                            child: Hero(
                              tag: "someTag",
                              child:
                              Image.network(snapshot.data!.imageUrl),
                            ),
                          )),
                      RichText(
                        text:
                        TextSpan(children: snapshot.data!.richDescription),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return LinearProgressIndicator();
            }
          },

        ),
      ),
    );
  }
}
