import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:projects/api/loginHandler.dart';
import '../config.dart';


class UploadService {
  static const WIKIMEDIA_API = Config.WIKIMEDIA_API;

  void uploadImage(XFile image, String fileName, String title, String description, String author,
      String license, DateTime date) async {
      var response = await _sendRequest(image, fileName, title, description, author, license, date, await getCsrfToken());
      print("Response stream data: " + response.toString());
  }


   Future<http.Response> _sendRequest(XFile image, String fileName, String title, String description, String author,
      String license, DateTime date, String csrfToken) async {
      var request = http.MultipartRequest('POST', Uri.parse(WIKIMEDIA_API));
      request.fields['filename'] = fileName;
      request.fields['text'] = description;
      request.fields['token'] = csrfToken;

      request.files.add(await _convertToMultiPartFile(image, fileName));

      var streamResponse = await request.send();
      return http.Response.fromStream(streamResponse);
  }

  Future<String> getCsrfToken() async { // Get a CSRF Token (https://www.mediawiki.org/wiki/API:Tokens)
    print(_getAccessToken());
    Future<http.Response> response = http.get(
        Uri.parse('$WIKIMEDIA_API?action=query&meta=tokens&format=json'),
        headers: <String, String>{
          'Authorization':'Bearer ${await _getAccessToken()}',
        },
    );
    var responseJson = await response;
    if(responseJson.statusCode == 200){
      var responseData = json.decode(responseJson.body);
      return responseData['csrftoken'];
    }else{
      throw("Could not get CSRF Token. Status Code: " + responseJson.statusCode.toString());
    }
  }

  Future<http.MultipartFile> _convertToMultiPartFile (XFile image, String fileName) async {
    var bytes = await image.readAsBytes();
    return http.MultipartFile.fromBytes('picture', bytes, filename: fileName);
  }

  Future<String> _getAccessToken() async {
    Userdata? data = await LoginHandler().getUserInformationFromFile();
    if(data != null){
      return data.accessToken;
    }else{
      throw("Could not get access token. Userdata is null");
    }
  }





}
