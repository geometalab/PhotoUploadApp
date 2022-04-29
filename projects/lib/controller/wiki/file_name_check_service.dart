import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projects/config.dart';
import 'package:projects/model/exceptions/request_exception.dart';

class FilenameCheckService {
  Future<bool> fileExists(String filename, String fileType) async {
    bool missing = false;
    bool known = false;
    String url =
        "${Config.wikimediaApi}?action=query&titles=File:$filename$fileType&format=json";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      Map queryResults = responseData['query'];
      queryResults = queryResults['pages'];
      queryResults = queryResults[queryResults.keys.first];
      if (queryResults.containsKey("missing")) {
        missing = true;
      }
      if (queryResults.containsKey("known")) {
        known = true;
      }
      return !(missing &&
          !known); // If both known and missing are false or true, or only known is true, a file with this name already exists.
    } else {
      throw RequestException(
          "Error while checking if file name exists", response);
    }
  }
}
