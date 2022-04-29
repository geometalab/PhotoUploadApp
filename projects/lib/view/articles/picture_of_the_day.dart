import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/picture_of_the_day_service.dart';
import 'package:projects/style/hero_photo_view_route_wrapper.dart';
import 'package:projects/style/text_styles.dart';

class PictureOfTheDayArticle extends StatelessWidget {
  const PictureOfTheDayArticle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    PictureOfTheDayService potd = PictureOfTheDayService();
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
                          child: Hero(
                            tag: "someTag",
                            child: Image.network(snapshot.data!.imageUrl),
                          )),
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0)),
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
