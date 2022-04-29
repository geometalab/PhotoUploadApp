import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:projects/config.dart';
import 'package:projects/style/themes.dart';
import '../../model/exceptions/requestException.dart';
import '../../style/themes.dart';

class ImageService {
  Future<Widget> getCategoryThumbnail(String category) async {
    List<ImageURL> urls = await _getImageURLs(category, 150, 1);
    if (urls.isEmpty) {
      return Container(
        color: CustomColors.NO_IMAGE_COLOR,
        child: const Center(
          child: Icon(Icons.image_not_supported,
              color: CustomColors.NO_IMAGE_CONTENTS_COLOR),
        ),
      );
    }
    return Image.network(
      urls[0].url,
      fit: BoxFit.cover,
    );

    // Resources:
    // https://magnus-toolserver.toolforge.org/commonsapi.php
    // https://commons.wikimedia.org/w/api.php?action=query&list=categorymembers&cmtype=file&cmtitle=Category:Hochstollen&format=json
  }

  Future<List<ImageURL>> getCategoryImages(
      String category, int width, int limit) async {
    List<ImageURL> urls = await _getImageURLs(category, width, limit);
    List<ImageURL> returnUrls = List.empty(growable: true);
    for (int i = 0; i < urls.length && i < limit; i++) {
      returnUrls.add(urls[i]);
    }
    return returnUrls;
  }

  Future<List<ImageURL>> _getImageURLs(
      String category, int width, int limit) async {
    String url =
        "${Config.wikimediaApi}?action=query&list=categorymembers&cmtype=file&cmtitle=Category:$category&cmlimit=$limit&format=json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      var query = responseData['query'];
      query = query['categorymembers'];

      List<ImageURL> urlList = List.empty(growable: true);
      String urlPrefix =
          "https://upload.wikimedia.org/wikipedia/commons/thumb/";

      for (int i = 0; i < query.length; i++) {
        var data = query[i] as Map;
        String filename = data.values.elementAt(2);
        filename = filename.substring(5);
        String urlFilename = filename.replaceAll(" ", "_");

        var hashedFileName = md5
            .convert(utf8.encode(urlFilename))
            .toString(); // To get the URL of the direct Image, we need to hash the file name and use
        var hashUrlPart = hashedFileName.substring(0, 1) +
            "/" +
            hashedFileName.substring(0, 2) +
            "/"; // the first char & the two first chars in the url per https://stackoverflow.com/questions/33689980/get-thumbnail-image-from-wikimedia-commons

        var params = "/${width.toString()}px-" + urlFilename + ".jpg";

        urlList.add(ImageURL(
            filename, (urlPrefix + hashUrlPart + urlFilename + params)));
      }
      return urlList;
    } else {
      throw RequestException(
          "Error while getting the thumbnail image urls.", response);
    }
  }
}

class ImageURL {
  String name;
  String url;

  ImageURL(this.name, this.url);
}
