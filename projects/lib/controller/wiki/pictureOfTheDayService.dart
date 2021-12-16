import 'dart:core';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/internal/actionHelper.dart';
import 'package:projects/style/textStyles.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/io_client.dart';

class PictureOfTheDayService {
  static const FEED_URL =
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

    var response = await client.get(Uri.parse(FEED_URL));
    var channel = RssFeed.parse(response.body);
    client.close();
    if (channel.items == null || channel.items!.isEmpty) {
      throw ("Picture of the day data cannot be retrieved from RSS Feed.");
    }
    var day = channel.items![channel.items!.length - 1 - daysSince];

    PictureOfTheDay tempPOTD = PictureOfTheDay(
        imageUrl: _getImageUrl(day.description!, 900),
        richDescription: _getRichDescription(day.description!),
        pubDate: day.pubDate!);
    tempPOTD.description = (_getDescription(tempPOTD.richDescription));
    _pictureOfTheDay = tempPOTD;
    return tempPOTD;
  }

  Future<PictureOfTheDay> getPictureOfTheDayAsync() async {
    if (_pictureOfTheDay == null) {
      _pictureOfTheDay = await getItemFromFeed(0);
    } else if (_pictureOfTheDay!.pubDate
        .isBefore(DateTime.now().subtract(Duration(days: 1)))) {
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
          imageUrl: "", richDescription: List.empty(), pubDate: DateTime.now());
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
  List<TextSpan> _getRichDescription(String desc) {
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

  String _getDescription(List<TextSpan> spans) {
    String desc = "";
    for (TextSpan span in spans) {
      desc += span.text!;
    }
    return desc;
  }

  List<TextSpan> _convertHtmlTags(String input) {
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
        if (input.substring(position, position + 3) == "<i>") {
          endIndex = input.indexOf("</i>", position);
          spans.add(TextSpan(
            text: input.substring(position + 3, endIndex),
          ));
          position = endIndex + 4;
        } else {
          // If tag is not a <i> tag (so probably a <a> tag)
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
                ActionHelper().launchUrl(href);
              },
          ));
          position = endIndex +
              4; // Set position to current position & skip the </a> tag
        }
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
        ));
        position = endIndex;
      }
    }
    return spans;
  }
}

class PictureOfTheDay {
  String title;
  String? link;
  String imageUrl;
  String description;
  List<TextSpan> richDescription;
  DateTime pubDate;

  PictureOfTheDay(
      {this.title = "Picture of the Day",
      required this.imageUrl,
      this.link,
      this.description = "",
      required this.richDescription,
      required this.pubDate});
}
