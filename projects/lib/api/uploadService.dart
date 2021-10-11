import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';
import 'package:projects/api/loginHandler.dart';
import '../config.dart';
import 'package:http_parser/http_parser.dart';


// TODO investigate file names on wiki commons and maybe autogenerate to avoid duplicates

class UploadService {
  static const WIKIMEDIA_API = Config.WIKIMEDIA_API;

  void uploadImage(XFile image, String fileName, String title, String description, String author,
      String license, DateTime date) async {
      var map = await _getCsrfToken();
      String token = map["tokens"]["csrftoken"];
      await _checkCsrfToken(token);
      // var response = await _sendRequest(image, fileName, title, description, author, license, date, token);
      // print("Response stream data: " + response.toString());
  }

   Future<http.Response> _sendRequest(XFile image, String fileName, String title, String description, String author,
      String license, DateTime date, String csrfToken) async {
      var request = http.MultipartRequest('POST', Uri.parse(
          "$WIKIMEDIA_API?format=json"
          + "&action=upload"
          + "&filename=$fileName"
      ));
      request.fields['token'] = csrfToken;
      request.files.add(await _convertToMultiPartFile(image, fileName));
      print(request.fields);

      var streamResponse = await request.send();
      return http.Response.fromStream(streamResponse);
  }

  _checkCsrfToken(String token) async {
    Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_API?action=checktoken&type=csrf&format=json'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded '
        },
        body: <String, String>{
          'token': token,
        });
    var responseData = await response;
    if (responseData.statusCode == 200) {
      var responseJson = json.decode(responseData.body);
      Userdata data = Userdata(
          refreshToken: responseJson['refresh_token'],
          accessToken: responseJson['access_token']);
      return data;
    } else {
      throw ("Could not check token. Response Code ${responseData.bodyBytes}");
    }
  }
  /*
    Map bodyData = {
      'token': token
    };
    var body = json.encode(bodyData);
    Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_API?action=checktoken&type=csrf&format=json'),
        headers: <String, String>{
          'Content-Type': 'application/json'
        },
        body: body
    );
    */

  /*
  Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_API?action=checktoken&type=csrf&format=json'),
        headers: <String, String>{
          'Content-Type': 'application/json'
        },
        body: <String, String>{
          'token': token,
        });
   */

  /*
  var body = "token=$token";
    Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_API?action=checktoken&type=csrf&format=json'),
        headers: <String, String>{
          'Content-Type': 'text/plain'
        },
        body: body);
   */

  Future<Map> _getCsrfToken() async { // Get a CSRF Token (https://www.mediawiki.org/wiki/API:Tokens)
    Future<http.Response> response = http.get(
        Uri.parse('$WIKIMEDIA_API?action=query&meta=tokens&format=json'),
        headers: <String, String>{
          'Authorization':'Bearer ${await _getAccessToken()}',
        },
    );
    var responseJson = await response;
    if(responseJson.statusCode == 200){
      var responseData = json.decode(responseJson.body);
      if(responseData.containsKey('query')){
        return responseData['query'];
      }else{
        throw("Could not get CSRF Token: response does not contain \"query\".");
      }
    }else{
      throw("Could not get CSRF Token: Bad Response. Status Code: " + responseJson.statusCode.toString());
    }
  }

  Future<http.MultipartFile> _convertToMultiPartFile (XFile image, String fileName) async {
    File imageFile = File(image.path);

    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    var length = await imageFile.length();

    http.MultipartFile multipartFile = new http.MultipartFile('file', stream, length, filename: fileName);
    return multipartFile;
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
