import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:projects/controller/internal/action_helper.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/io_client.dart';

class PictureOfTheDayService {
  static const feedURL =
      "https://commons.wikimedia.org/w/api.php?action=featuredfeed&feed=potd&feedformat=rss&language=en";
  PictureOfTheDay? _pictureOfTheDay;

  static final PictureOfTheDayService _pictureOfTheDayService =
      PictureOfTheDayService._internal();

  factory PictureOfTheDayService() {
    return _pictureOfTheDayService;
  }

  PictureOfTheDayService._internal() {
    getItemFromFeed(0); // On initialisation, get POTD from RSS feed
  }

  openPotdWeb() {
    ActionHelper().launchUrl(
        "https://commons.wikimedia.org/wiki/Commons:Picture_of_the_day"); // TODO open the actual page of POTD, not this site
  }

  Future<PictureOfTheDay> getItemFromFeed(int daysSince) async {
    final client = IOClient(HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true));

    var response = await client.get(Uri.parse(feedURL));
    var channel = RssFeed.parse(response.body);
    client.close();
    if (channel.items == null || channel.items!.isEmpty) {
      throw ("Picture of the day data cannot be retrieved from RSS Feed.");
    }
    var day = channel.items![channel.items!.length - 1 - daysSince];

    PictureOfTheDay tempPOTD = PictureOfTheDay(
        imageUrl: _getImageUrl(day.description!, 900),
        description: _getDescription(day.description!),
        pubDate: day.pubDate!);
    _pictureOfTheDay = tempPOTD;
    return tempPOTD;
  }

  Future<PictureOfTheDay> getPictureOfTheDayAsync() async {
    if (_pictureOfTheDay == null) {
      _pictureOfTheDay = await getItemFromFeed(0);
    } else if (_pictureOfTheDay!.pubDate
        .isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      _pictureOfTheDay = await getItemFromFeed(0);
    }
    return _pictureOfTheDay!;
  }

  PictureOfTheDay getPictureOfTheDay() {
    getItemFromFeed(0).then((value) => _pictureOfTheDay = value);
    if (_pictureOfTheDay != null) {
      return _pictureOfTheDay!;
    } else {
      return PictureOfTheDay(
          imageUrl: "", description: Html(data: ""), pubDate: DateTime.now());
    }
  }

  String _getImageUrl(String description, int width) {
    int startIndex = description.indexOf("src=") + 5;
    int endIndex = description.indexOf("decoding=") - 2;
    String url = description.substring(startIndex, endIndex);
    url = url.replaceFirst("300px", width.toString() + "px");
    return url;
  }

  // Get the image description with hyperlinks out of html code supplied by RSS
  Html _getDescription(String desc) {
    // Trim it to roughly the description to make searching easier
    int startIndex = desc.indexOf("description en");
    int endIndex = desc.lastIndexOf("</div>");
    desc = desc.substring(startIndex, endIndex);

    // Trim out all the div tags
    startIndex = desc.indexOf(">") + 1;
    endIndex = desc.indexOf("</div>");
    desc = desc.substring(startIndex, endIndex);

    // Now we are left with only description, but it still contains <a> tags for hyperlinks and other content.
    return _convertHtmlTags(desc);
  }

  Html _convertHtmlTags(String input) {
    return Html(
      style: {
        "*": Style(
          padding: const EdgeInsets.all(0),
          margin: const EdgeInsets.all(0),
          fontSize: FontSize.large,
        ),
      },
      data: input,
      onLinkTap: (url, _, __, ___) {
        if (url != null) {
          ActionHelper().launchUrl(url);
        }
      },
    );
  }
}

class PictureOfTheDay {
  String title;
  String? link;
  String imageUrl;
  Html description;
  DateTime pubDate;

  PictureOfTheDay(
      {this.title = "Picture of the Day",
      required this.imageUrl,
      this.link,
      required this.description,
      required this.pubDate});
}
