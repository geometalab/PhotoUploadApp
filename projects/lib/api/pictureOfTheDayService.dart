import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';
import 'package:url_launcher/url_launcher.dart';
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

  String getImageUrl(PictureOfTheDay pictureOfTheDay, int width) {
    String description = pictureOfTheDay.description;
    int startIndex = description.indexOf("src=") + 5;
    int endIndex = description.indexOf("decoding=") - 2;
    String url = description.substring(startIndex, endIndex);
    url = url.replaceFirst("300px", width.toString() + "px");
    return url;
  }

  // Get the image description with hyperlinks out of html code supplied by RSS
  List<TextSpan> getImageDescription(PictureOfTheDay pictureOfTheDay) {
    // Trim it to roughly the description to make searching easier
    String desc = pictureOfTheDay.description;
    int startIndex = desc.indexOf("description en");
    int endIndex = desc.lastIndexOf("</div>");
    desc = desc.substring(startIndex, endIndex);

    // Trim out all the div tags
    startIndex = desc.indexOf(">") + 1;
    endIndex = desc.indexOf("</div>");
    desc = desc.substring(startIndex, endIndex);

    // Now we are left with only description, but it still contains <a> tags for hyperlinks and other content.
    return convertHtmlTags(desc);
  }

  List<TextSpan> convertHtmlTags(String input) {
    List<TextSpan> spans = List.empty(
        growable:
            true); // We need to use text spans in rich text in order to make clickable hyperlinks
    int position =
        0; // Index of where in the string we are to work through it in sequence
    int startIndex = 0;
    int endIndex = 0;
    while (position < input.length) {
      // While ends when worked through the whole string
      if (input[position] == "<") {
        // If next is a tag
        // Extract url
        startIndex = input.indexOf("href=", position) + 6;
        position = startIndex;
        endIndex = input.indexOf("\"", position);
        String href = input.substring(startIndex, endIndex);

        // When a redirect is to commons, it is a relative url in the RSS Feed, so we need to add the wikimedia url by ourselves.
        if (href.startsWith("/wiki/")) {
          href = "https://commons.wikimedia.org" + href;
        }

        // Extract link text
        startIndex = input.indexOf(">", position) + 1;
        endIndex = input.indexOf("</a>", position);
        spans.add(TextSpan(
          text: input.substring(startIndex, endIndex),
          style: hyperlink,
          recognizer: new TapGestureRecognizer()
            ..onTap = () {
              _openURL(href);
            },
        ));
        position = endIndex +
            4; // Set position to current position & skip the </a> tag
      } else {
        // If next is normal tag
        endIndex =
            input.indexOf("<", position); // Find the start of the next tag
        if (endIndex == -1) {
          // If there is no next tag (which means string is worked through after this)
          endIndex = input.length;
        }
        spans.add(TextSpan(
          text: input.substring(position, endIndex),
          style: new TextStyle(color: Colors.black45),
        ));
        position = endIndex;
      }
    }
    return spans;
  }

  Future<void> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
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
