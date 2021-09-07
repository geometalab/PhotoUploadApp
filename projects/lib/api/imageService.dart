import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';

class ImageService {
  Future<Image> getCategoryThumbnail (String category) async {
    List<String> urls = await getImageURLs(category, 150);
    return Image.network(urls[0]);

    // Resources:
    // https://magnus-toolserver.toolforge.org/commonsapi.php
    // https://commons.wikimedia.org/w/api.php?action=query&list=categorymembers&cmtype=file&cmtitle=Category:Hochstollen&format=json
  }

  List<Image> getCategoryImages (String category, int width){
    throw UnimplementedError();
  }

  Future<List<String>> getImageURLs (String category, int width) async {
    String url = "https://commons.wikimedia.org/w/api.php?action=query&list=categorymembers&cmtype=file&cmtitle=Category:$category&format=json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      var query = responseData['query'];
      query = query['categorymembers'];

      List<String> urlList = List.empty(growable: true);
      String urlPrefix = "https://upload.wikimedia.org/wikipedia/commons/thumb/";

      for (int i = 0; i < query.length; i++){
        var data = query[i] as Map;
        String filename = data.values.elementAt(2);
        filename = filename.substring(5);
        filename = filename.replaceAll(" ", "_");

        var hashedFileName = md5.convert(utf8.encode(filename)).toString();                             // To get the URL of the direct Image, we need to hash the file name and use
        var hashUrlPart = hashedFileName.substring(0,1) + "/" + hashedFileName.substring(0,2) + "/";    // the first char & the two first chars in the url per https://stackoverflow.com/questions/33689980/get-thumbnail-image-from-wikimedia-commons

        var params = "/${width.toString()}px-" + filename + ".jpg";

        urlList.add(urlPrefix + hashUrlPart + filename + params);
      }

      return urlList;
    }else{
      throw("Image URLs could not be accessed through API. Status code: " + response.statusCode.toString());
    }
  }
}



