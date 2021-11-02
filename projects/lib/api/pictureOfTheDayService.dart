import 'dart:core';
import 'dart:io';
import 'package:webfeed/webfeed.dart';
import 'package:http/io_client.dart';

class PictureOfTheDayService {
  static const FEED_URL =
      "https://commons.wikimedia.org/w/api.php?action=featuredfeed&feed=potd&feedformat=rss&language=en";
  PictureOfTheDay? _pictureOfTheDay;

  static final PictureOfTheDayService _config =
      PictureOfTheDayService._internal();
  factory PictureOfTheDayService() {
    return _config;
  }
  PictureOfTheDayService._internal();

  Future<PictureOfTheDay> getItemFromFeed(int daysSince) async {
    final client = IOClient(HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true));

    var response = await client.get(Uri.parse(FEED_URL));
    var channel = RssFeed.parse(response.body);
    client.close();
    if (channel.items == null || channel.items!.isEmpty) {
      throw ("Picture of the day data cannot be retrieved from RSS Feed.");
    }
    var recentDay = channel.items![channel.items!.length - 1 - daysSince];
    return PictureOfTheDay(
        title: recentDay.title!,
        link: recentDay.link!,
        description: recentDay.description!,
        pubDate: recentDay.pubDate!);
  }

  Future<PictureOfTheDay> getPictureOfTheDay() async {
    if (_pictureOfTheDay == null) {
      _pictureOfTheDay = await getItemFromFeed(0);
    } else if (_pictureOfTheDay!.pubDate
        .isBefore(DateTime.now().subtract(Duration(days: 1)))) {
      _pictureOfTheDay = await getItemFromFeed(0);
    }
    return _pictureOfTheDay!;
  }

  String getImageUrl(PictureOfTheDay pictureOfTheDay) {
    String description = pictureOfTheDay.description;
    int startIndex = description.indexOf("src=") + 5;
    int endIndex = description.indexOf("decoding=") - 2;
    return description.substring(startIndex, endIndex);
  }
}

class PictureOfTheDay {
  String title;
  String link;
  String description;
  DateTime pubDate;

  PictureOfTheDay(
      {required this.title,
      required this.link,
      required this.description,
      required this.pubDate});
}
