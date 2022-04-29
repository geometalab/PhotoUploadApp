import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/pictureOfTheDayService.dart';
import 'package:projects/style/heroPhotoViewRouteWrapper.dart';
import 'package:projects/style/textStyles.dart';

class PictureOfTheDayArticle extends StatelessWidget {
  final PictureOfTheDayService potd = PictureOfTheDayService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Picture of the day"),
      ),
      body: Center(
        child: FutureBuilder(
          future: PictureOfTheDayService().getPictureOfTheDayAsync(),
          builder:
              (BuildContext context, AsyncSnapshot<PictureOfTheDay> snapshot) {
            if (snapshot.hasData) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Wikimedia Picture of the day",
                    style: headerText,
                  ),
                  const Divider(),
                  Column(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        HeroPhotoViewRouteWrapper(
                                          imageProvider: NetworkImage(
                                            snapshot.data!.imageUrl,
                                          ),
                                        )));
                          },
                          child: Container(
                            child: Hero(
                              tag: "someTag",
                              child: Image.network(snapshot.data!.imageUrl),
                            ),
                          )),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                      snapshot.data!.description,
                      TextButton(
                        onPressed: () {
                          potd.openPotdWeb();
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.public),
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2)),
                            Text("View in browser")
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return const LinearProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
