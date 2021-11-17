import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:projects/api/loginHandler.dart';
import 'package:projects/fragments/uploadFlow/descriptionFragment.dart';
import '../config.dart';

// TODO investigate file names on wiki commons and maybe autogenerate to avoid duplicates (or check if already taken)

class UploadService {
  static const WIKIMEDIA_API = Config.WIKIMEDIA_API;

  uploadImage(
      XFile image,
      String fileName,
      String source,
      List<Description> description,
      String author,
      String license,
      DateTime date,
      List<String> categories,
      List<String> depictions) async {
    UploadProgressStream progressStream = UploadProgressStream();

    int progressNumber = 3; // represents times progress() is called

    progressStream.reset();
    await (Future.delayed(Duration(milliseconds: 500)));
    progressStream.progress(progressNumber);

    var map = await _getCsrfToken();
    String token = map["tokens"]["csrftoken"];
    await _sendImage(image, fileName, token);

    progressStream.progress(progressNumber);

    map = await _getCsrfToken();
    token = map["tokens"]["csrftoken"];
    await _editDetails(author, description, license, source, date, categories,
        fileName, token);

    progressStream.progress(progressNumber);

    // Simulated _editDepictions()
    await (Future.delayed(Duration(milliseconds: 700)));
    progressStream.doneUploading();
  }

  Future<http.Response> _sendImage(
      XFile image, String fileName, String csrfToken) async {
    var request = http.MultipartRequest(
        'POST',
        Uri.parse("$WIKIMEDIA_API?format=json" +
            "&action=upload" +
            "&filename=$fileName"));
    request.headers['Authorization'] = "Bearer " + await _getAccessToken();
    request.fields['token'] = csrfToken;
    request.files.add(await _convertToMultiPartFile(image, fileName));
    print(request.headers.toString());

    var streamResponse = await request.send();
    return http.Response.fromStream(streamResponse);
  }

  Future<http.Response> _editDetails(
      String author,
      List<Description> description,
      String license,
      String source,
      DateTime date,
      List<String> categories,
      String filename,
      String token) async {
    String editSummary =
        'Added file details & description. Edited by Wikimedia Commons Uploader.'; // TODO insert final name once determined
    String descriptionString = "";

    for (Description description in description) {
      descriptionString +=
          '{{${description.language}|1=${description.content}}} ';
    }

    // TODO add "depicts"
    // File Description
    // DO NOT INDENT!
    String informationString = """
=={{int:filedesc}}== 
{{Information 
|description=$descriptionString 
|date=${date.year}-${date.month}-${date.day} 
|source=$source 
|author=$author 
|permission= 
|other versions= 
}}

=={{int:license-header}}==
{{${_convertLicense(license)}}}

""";

    for (String category in categories) {
      informationString += "[[Category:$category]] ";
    }

    Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_API?action=edit&format=json'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded ',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: <String, String>{
          'title': 'File:' + filename,
          'text': informationString,
          'summary': editSummary,
          'token': token,
        });
    var responseData = await response;
    if (responseData.statusCode == 200) {
      return response;
    } else {
      throw ("Could edit description. Response Code ${responseData.bodyBytes}");
    }
  }

  Future<http.Response> _editDepictions(
      List<String> depicts, String token) async {
    // TODO Implement _editDepictions
    throw UnimplementedError("_editDepictions is not implemented.");
  }

  // For debug purposes
  _checkCsrfToken(String token) async {
    Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_API?action=checktoken&type=csrf&format=json'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded ',
          'Authorization': 'Bearer ${await _getAccessToken()}',
        },
        body: <String, String>{
          'token': token,
        });
    var responseData = await response;
    if (responseData.statusCode == 200) {
      return;
    } else {
      throw ("Could not check token. Response Code ${responseData.bodyBytes}");
    }
  }

  Future<Map> _getCsrfToken() async {
    // Get a CSRF Token (https://www.mediawiki.org/wiki/API:Tokens)
    Future<http.Response> response = http.get(
      Uri.parse('$WIKIMEDIA_API?action=query&meta=tokens&format=json'),
      headers: <String, String>{
        'Authorization': 'Bearer ${await _getAccessToken()}',
      },
    );
    var responseJson = await response;
    if (responseJson.statusCode == 200) {
      var responseData = json.decode(responseJson.body);
      if (responseData.containsKey('query')) {
        return responseData['query'];
      } else {
        throw ("Could not get CSRF Token: response does not contain \"query\".");
      }
    } else {
      throw ("Could not get CSRF Token: Bad Response. Status Code: " +
          responseJson.statusCode.toString());
    }
  }

  Future<http.MultipartFile> _convertToMultiPartFile(
      XFile image, String fileName) async {
    File imageFile = File(image.path);

    var stream = new http.ByteStream(imageFile.openRead());
    stream.cast();
    var length = await imageFile.length();

    http.MultipartFile multipartFile =
        new http.MultipartFile('file', stream, length, filename: fileName);
    return multipartFile;
  }

  String _convertLicense(String license) {
    switch (license) {
      case 'CC0':
        {
          return "CC0";
        }
      case 'Attribution 3.0':
        {
          return "cc-by-3.0";
        }
      case 'Attribution-ShareAlike 3.0':
        {
          return "cc-by-sa-3.0";
        }
      case 'Attribution 4.0':
        {
          return "cc-by-4.0";
        }
      case 'Attribution-ShareAlike 4.0':
        {
          return "cc-by-sa-3.0";
        }
      default:
        {
          return license;
        }
    }
  }

  Future<String> _getAccessToken() async {
    Userdata? data = await LoginHandler().getUserInformationFromFile();
    if (data != null) {
      return data.accessToken;
    } else {
      throw ("Could not get access token. Userdata is null");
    }
  }
}

// Updates Listeners over the progress of a image & corresponding description upload
// Streams a double:
// 0.0 - 0.99 ->  Upload Progress
// 1.0        ->  Uploading finished
// 2.0        ->  is set a second after doneDownloading() is called
class UploadProgressStream {
  double _progress = 0.0;
  static StreamController<double> _controller =
      StreamController<double>.broadcast();

  reset() {
    _progress = 0.0;
    _controller.add(_progress);
  }

  progress(int count) {
    // int count represents how many times progressStream.progress() is called,
    // which helps calculate how much a single progress() should advance
    // the progress value
    double _progressValue = 1.0 / (count + 1);
    _progress += _progressValue;
    _controller.add(_progress);
  }

  doneUploading() async {
    _progress = 1.0;
    _controller.add(_progress);
    await Future.delayed(Duration(milliseconds: 1000));
    doneProcessing();
  }

  doneProcessing() {
    _progress = 2.0;
    _controller.add(_progress);
  }

  void dispose() {
    _controller.close();
  }

  Stream<double> get stream => _controller.stream;
}
