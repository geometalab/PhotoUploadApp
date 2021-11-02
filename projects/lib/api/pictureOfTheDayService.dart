import 'dart:io';
import 'package:webfeed/webfeed.dart';
import 'package:http/io_client.dart';

class PictureOfTheDayService {
  static const FEED_URL = "https://commons.wikimedia.org/w/api.php?action=featuredfeed&feed=potd&feedformat=rss&language=en";

  Future<PictureOfTheDay> getItem(int daysSince) async {
    final client = IOClient(HttpClient()
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) => true));


    var response = await client.get(
        Uri.parse(FEED_URL));
    var channel = RssFeed.parse(response.body);
    client.close();
    if(channel.items == null || channel.items!.isEmpty){
      throw("Picture of the day data cannot be retrieved from RSS Feed.");
    }
    var recentDay = channel.items![channel.items!.length - 1 - daysSince];
    return PictureOfTheDay(title: recentDay.title, link: recentDay.link, description: recentDay.description);
  }

  String getImageUrl (PictureOfTheDay pictureOfTheDay) {
    if(pictureOfTheDay.description == null) {
      throw("Picture of the Day description is null");
    } else {
      String description = pictureOfTheDay.description!;
      int startIndex = description.indexOf("src=") + 5;
      int endIndex = description.indexOf("decoding=") - 2;
      return description.substring(startIndex, endIndex);
    }
  }
}

class PictureOfTheDay {
  String? title;
  String? link;
  String? description;
  DateTime? pubDate;

  PictureOfTheDay({this.title, this.link, this.description, this.pubDate});
}