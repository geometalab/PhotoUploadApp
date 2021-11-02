import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projects/config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

// TODO Include a PKCE Code challange https://duckduckgo.com/?q=pkce+code+challenge

class LoginHandler {
  static const CLIENT_ID = Config.CLIENT_ID;
  static const CREDENTIALS_FILE = Config.CREDENTIALS_FILE;
  static const WIKIMEDIA_REST = Config.WIKIMEDIA_REST;

  // Making class a singleton
  static final LoginHandler _loginHandler = LoginHandler._internal();
  factory LoginHandler() {
    return _loginHandler;
  }
  LoginHandler._internal();

  checkCredentials() async {
    try {
      Userdata? data = await getUserInformationFromFile();
      if (data != null) {
        data = await refreshAccessToken();
        data = await getUserInformationFromAPI(data);
        data.lastCheck = DateTime.now();
        saveUserDataToFile(data);
      }
    } catch (e) {
      throw("Could not check Credentials successfully. Error: " + e.toString());
    }
  }

  Future<bool> isLoggedIn() async {
    Userdata? data = await getUserInformationFromFile();
    if (data != null && data.username != "") {
      if (data.lastCheck
          .isBefore(DateTime.now().subtract(Duration(hours: 1)))) {
        checkCredentials(); // If the last check happened more than a hour ago, refresh tokens & data
      }
      return true;
    } else
      return false;
  }

  logOut() {
    _deleteUserDataInFile();
  }

  openWebLogin() {
    String url =
        "$WIKIMEDIA_REST/oauth2/authorize?client_id=$CLIENT_ID&response_type=code";
    _openURL(url);
  }

  openWebSignUp() {
    // TODO Return to app directly? https://www.mediawiki.org/wiki/Onboarding_new_Wikipedians/Account_creation_pathways
    String url =
        "https://en.wikipedia.org/w/index.php?title=Special:CreateAccount";
    _openURL(url);
  }

  openMediaAccount(String username) {
    String url =
        "https://commons.wikimedia.org/w/index.php?title=Special:ListFiles/$username";
    _openURL(url);
    // TODO make sure what function should do
  }

  Future<Userdata> getTokens(String authCode) async {
    // Resources: https://api.wikimedia.org/wiki/Documentation/Getting_started/Authentication#User_authentication
    String clientSecret = await _getClientSecret();
    Future<http.Response> response = http.post(
        Uri.parse('$WIKIMEDIA_REST/oauth2/access_token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        },
        body: <String, String>{
          'grant_type': 'authorization_code',
          'code': authCode,
          'client_id': CLIENT_ID,
          'client_secret': clientSecret,
        });

    var responseData = await response;
    if (responseData.statusCode == 200) {
      var responseJson = json.decode(responseData.body);
      Userdata data = Userdata(
          refreshToken: responseJson['refresh_token'],
          accessToken: responseJson['access_token']);
      return data;
    } else {
      throw ("Could not get tokens. Response Code ${responseData.bodyBytes}");
    }
  }

  Future<Userdata> refreshAccessToken() async {
    Userdata? userdata = await getUserInformationFromFile();
    String clientSecret = await _getClientSecret();
    if (userdata == null || userdata.refreshToken == "") {
      throw ("Tried to refresh access token but userdata.refreshToken is null or empty");
    } else {
      Future<http.Response> response = http.post(
          Uri.parse('$WIKIMEDIA_REST/oauth2/access_token'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          },
          body: <String, String>{
            'grant_type': 'refresh_token',
            'refresh_token': userdata.refreshToken,
            'client_id': CLIENT_ID,
            'client_secret': clientSecret,
          });
      var responseData = await response;
      if (responseData.statusCode == 200) {
        var responseJson = json.decode(responseData.body);
        Userdata data = Userdata(
            accessToken: responseJson['access_token'],
            refreshToken: responseJson['refresh_token']);
        return data;
      } else {
        // TODO investigate which codes get returned when app permission revoked/wrong access token etc.. (to then delete local user data)
        throw ("Could not refresh access token. Status code ${responseData.statusCode}");
      }
    }
  }

  saveUserDataToFile(Userdata data) async {
    Userdata? dataFromFile = await getUserInformationFromFile();
    if (dataFromFile != null) {
      // Only new information replaces old information if passed Userdata does not have every field filled out.
      if (data.refreshToken != "") {
        dataFromFile.refreshToken = data.refreshToken;
      }
      if (data.accessToken != "") {
        dataFromFile.accessToken = data.accessToken;
      }
      if (data.username != "") {
        dataFromFile.username = data.username;
      }
      if (data.email != "") {
        dataFromFile.email = data.email;
      }
      if (data.editCount != 0) {
        dataFromFile.editCount = data.editCount;
      }
      data = dataFromFile;
    }
    _writeToFile(CREDENTIALS_FILE, data.toJson());
  }

  Future<Userdata?> getUserInformationFromFile() async {
    String jsonString = await _readFromFile(CREDENTIALS_FILE);
    if (jsonString == "") {
      return null;
    } else {
      Userdata userdata = Userdata().fromJson(jsonString);
      if (userdata.refreshToken == "" || userdata.accessToken == "") {
        return null;
      } else {
        return userdata;
      }
    }
  }

  Future<Userdata> getUserInformationFromAPI(Userdata data) async {
    if (data.accessToken != "") {
      Future<http.Response> response = http.get(
        Uri.parse('$WIKIMEDIA_REST/oauth2/resource/profile'),
        headers: <String, String>{
          'Authorization': 'Bearer ${data.accessToken}',
        },
      );
      var responseJson = await response;
      var responseData = json.decode(responseJson.body);
      if(responseJson.statusCode == 200){
        Userdata tokenData = Userdata(
          username: responseData['username'],
          editCount: responseData['editcount'],
          email: responseData['email'],
          realName: responseData['realname'],
          groups: responseData['groups'],
          rights: responseData['rights'],
          grants: responseData['grants'],
          accessToken: data.accessToken,
          refreshToken: data.refreshToken,
        );
        return tokenData;
      } else {
        throw(Exception("No 200 Status on API response. Status Code ${responseJson.statusCode} has been returned instead."));
      }
    } else {
      throw (Exception("Access Token is empty"));
    }
  }

  Future<void> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  _writeToFile(String dir, String text) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final file = File(appDocDirectory.path + "/" + dir);
    return file.writeAsString(text);
  }

  Future<String> _readFromFile(String dir) async {
    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    final file = File(appDocDirectory.path + "/" + dir);
    return file.readAsString();
  }

  _deleteUserDataInFile() {
    _writeToFile(CREDENTIALS_FILE, "");
  }

  Future<String> _getClientSecret() async {
    await dotenv.load(fileName: ".env");
    String? clientSecret = dotenv
        .env['SECRET_TOKEN']; // Get the secret token from the local .env file
    if (clientSecret == null) {
      throw ("Secret token is not provided in .env");
    }
    return clientSecret;
  }
}

class Userdata {
  String username;
  String realName;
  String email;
  int editCount;
  String accessToken;
  String refreshToken;
  List<dynamic> groups;
  List<dynamic> rights;
  List<dynamic> grants;
  DateTime lastCheck;

  Userdata({
    this.username = "",
    this.realName = "",
    this.email = "",
    this.editCount = 0,
    this.accessToken = "",
    this.refreshToken = "",
    List<dynamic>? groups,
    List<dynamic>? rights,
    List<dynamic>? grants,
    DateTime? lastCheck,
  })  : groups = groups ?? List.empty(),
        rights = rights ?? List.empty(),
        grants = grants ?? List.empty(),
        lastCheck = DateTime.now();

  Userdata fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return new Userdata(
        username: json['username'],
        realName: json['realname'],
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        email: json['email'],
        editCount: int.parse(json['editCount']),
        groups: json['groups'],
        rights: json['rights'],
        grants: json['grants'],
        lastCheck: DateTime.parse(json['lastCheck']));
  }

  String toJson() {
    return jsonEncode(_toMap());
  }

  Map<String, dynamic> _toMap() {
    return {
      'username': username,
      'realname': realName,
      'email': email,
      'editCount': editCount.toString(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'groups': groups,
      'rights': rights,
      'grants': grants,
      'lastCheck': lastCheck.toString()
    };
  }
}
