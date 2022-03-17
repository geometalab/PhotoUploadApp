import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/wiki/loginHandler.dart';
import 'package:projects/model/description.dart';
import '../../model/datasets.dart' as data;
import '../../config.dart';

// TODO get response in case of error and extract error message, which then should be thrown to catch for the progress indicator

class UploadService {
  static const WIKIMEDIA_API = Config.WIKIMEDIA_API;

  uploadImage(
      List<XFile> images,
      String fileName,
      String fileType,
      String source,
      List<Description> description,
      String author,
      String license,
      DateTime date,
      List<String> categories,
      List<String> depictions) async {
    UploadProgressStream progressStream = UploadProgressStream();
    int progressNumber =
        3 * images.length; // represents times progress() is called
    var map;
    String token;

    progressStream.reset();
    await (Future.delayed(Duration(milliseconds: 500)));

    try {
      for (int i = 0; i < images.length; i++) {
        XFile image = images[i];
        progressStream.progress(progressNumber);

        map = await _getCsrfToken();
        token = map["tokens"]["csrftoken"];
        String batchFileName = fileName + fileType;
        if (images.length != 1) {
          batchFileName = fileName + "_" + (i + 1).toString() + fileType;
        }
        await _sendImage(image, batchFileName, token);
        progressStream.progress(progressNumber);

        map = await _getCsrfToken();
        token = map["tokens"]["csrftoken"];
        await _editDetails(author, description, license, source, date,
            categories, batchFileName, token);
        progressStream.progress(progressNumber);

        // map = await _getCsrfToken();
        // token = map["tokens"]["csrftoken"];
        // _editDepictions(depictions, token);
        await (Future.delayed(Duration(milliseconds: 200)));
      }
      progressStream.doneUploading();
    } catch (e) {
      progressStream.error(e.toString());
      throw (e);
    }
  }

  simulatedUploadImage() async {
    // For debugging
    UploadProgressStream progressStream = UploadProgressStream();

    int progressNumber = 3; // represents times progress() is called

    progressStream.reset();
    await (Future.delayed(Duration(milliseconds: 200)));
    progressStream.progress(progressNumber);

    await (Future.delayed(Duration(milliseconds: 200)));

    progressStream.progress(progressNumber);

    await (Future.delayed(Duration(milliseconds: 200)));

    progressStream.progress(progressNumber);

    await (Future.delayed(Duration(milliseconds: 200)));

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
        'Added file details & description. Edited by Commons Uploader.';
    categories.add(
        "Images uploaded by Commons Uploader for Mobile"); // This category gets added to all uploaded images using this app.

    // File Description
    // DO NOT INDENT!
    String informationString = """
=={{int:filedesc}}== 
{{Information 
${_generateDescriptions(description)}
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
    await (Future.delayed(Duration(milliseconds: 700)));
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
    String? value = data.licences[license];
    if (value == null) {
      throw "Could not convert licences.";
    }
    return value;
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

String _generateDescriptions(List<Description> description) {
  String descriptionString = "|description=";

  for (Description description in description) {
    if (description.content.isNotEmpty) {
      descriptionString +=
          '{{${description.language}|1=${description.content}}} ';
    }
  }

  if (description.isEmpty) {
    descriptionString = "";
  }

  return descriptionString;
}

// Updates Listeners over the progress of a image & corresponding description upload
// Streams a double:
// 0.0 - 0.99 ->  Upload Progress
// 1.0        ->  Uploading finished
// 2.0        ->  is set a second after doneDownloading() is called
class UploadProgressStream {
  UploadStatus _status = UploadStatus(progress: 0.0);
  static StreamController<UploadStatus> _controller =
      StreamController<UploadStatus>.broadcast();

  reset() {
    _status = UploadStatus();
    _controller.add(_status);
  }

  progress(int count) {
    // int count represents how many times progressStream.progress() is called,
    // which helps calculate how much a single progress() should advance
    // the progress value
    double _progressValue = 1.0 / (count + 1);
    _status.addProgress(_progressValue);
    _controller.add(_status);
  }

  doneUploading() async {
    _status = UploadStatus(progress: 1.0);
    _controller.add(_status);
    await Future.delayed(Duration(milliseconds: 2000));
    doneProcessing();
  }

  doneProcessing() {
    _status.done = true;
    _controller.add(_status);
  }

  error(String message) {
    _status = UploadStatus(error: true, message: message);
    _controller.add(_status);
  }

  warning(String message) {
    _status.warning = true;
    _status.message = message;
    _controller.add(_status);
  }

  void dispose() {
    _controller.close();
  }

  Stream<UploadStatus> get stream => _controller.stream;
}

class UploadStatus {
  double progress;
  bool done;
  bool warning;
  bool error;
  String message;

  UploadStatus(
      {this.progress = 0.0,
      this.done = false,
      this.warning = false,
      this.error = false,
      this.message = ""});

  addProgress(double value) {
    progress += value;
  }
}
