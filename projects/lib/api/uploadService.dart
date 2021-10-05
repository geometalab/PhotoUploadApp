import 'dart:convert';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:projects/api/loginHandler.dart';

import '../config.dart';


class UploadService {
  static const WIKIMEDIA_API = Config.WIKIMEDIA_API;

  void uploadImage(XFile image, String fileName, String title, String description, String author,
      String license, DateTime date) async {
      var response = await _sendRequest(image, fileName, title, description, author, license, date, await _getCsrfToken());
      print("Response stream data: " + response.toString());
  }


   Future<Response> _sendRequest(XFile image, String fileName, String title, String description, String author,
      String license, DateTime date, String csrfToken) async {
      var request = MultipartRequest('POST', Uri.parse(WIKIMEDIA_API));
      request.fields['filename'] = fileName;
      request.fields['text'] = description;
      request.fields['token'] = csrfToken;

      request.files.add(await _convertToMultiPartFile(image, fileName));

      var streamResponse = await request.send();
      return Response.fromStream(streamResponse);
  }

  Future<String> _getCsrfToken() async { // Get a CSRF Token (https://www.mediawiki.org/wiki/API:Tokens)
    Future<Response> response = get(
        Uri.parse('$WIKIMEDIA_API?action=query&meta=tokens&format=json'),
        headers: <String, String>{
          'Authorization': 'Bearer ${_getAccessToken()}',
        }
    );
    var responseJson = await response;
    if(responseJson.statusCode == 200){
      var responseData = json.decode(responseJson.body);
      return responseData['csrftoken'];
    }else{
      throw("Could not get CSRF Token. Status Code: " + responseJson.statusCode.toString());
    }
  }

  Future<MultipartFile> _convertToMultiPartFile (XFile image, String fileName) async {
    var bytes = await image.readAsBytes();
    return MultipartFile.fromBytes('picture', bytes, filename: fileName);
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
