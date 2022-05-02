import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:projects/config.dart';
import 'package:projects/controller/internal/action_helper.dart';
import 'package:path_provider/path_provider.dart';

import '../../model/exceptions/request_exception.dart';

class LoginHandler {
  static const clientID = Config.clientID;
  static const credentialsFile = Config.credentialsFile;
  static const wikimediaRest = Config.wikimediaRest;
  static late String codeVerifier;

  final ActionHelper _actionHelper = ActionHelper();

  // Making class a singleton
  static final LoginHandler _loginHandler = LoginHandler._internal();
  factory LoginHandler() {
    return _loginHandler;
  }
  LoginHandler._internal();

  checkCredentials() async {
    Userdata? data = await getUserInformationFromFile();
    if (data != null) {
      data = await refreshAccessToken();
      if (data != null) {
        data = await getUserInformationFromAPI(data);
        data.lastCheck = DateTime.now();
        saveUserDataToFile(data);
      } else {
        // When 401 is returned to refreshAccessToken
        _deleteUserDataInFile();
      }
    }
  }

  processAuthCode(String authCode) async {
    Userdata userData = await getTokens(authCode);
    userData = await getUserInformationFromAPI(userData);
    userData.lastCheck = DateTime.now();
    await saveUserDataToFile(userData);
  }

  Future<bool> isLoggedIn() async {
    Userdata? data = await getUserInformationFromFile();
    if (data != null && data.username != "") {
      if (data.lastCheck
          .isBefore(DateTime.now().subtract(const Duration(hours: 1)))) {
        checkCredentials(); // If the last check happened more than a hour ago, refresh tokens & data
      }
      return true;
    } else {
      return false;
    }
  }

  logOut() async {
    await _deleteUserDataInFile();
  }

  openWebLogin() {
    codeVerifier = _generateCodeVerifier();
    String codeChallenge = _encryptCodeVerifier(codeVerifier);
    String url = "$wikimediaRest/oauth2/authorize"
        "?client_id=$clientID"
        "&response_type=code"
        "&code_challenge=$codeChallenge"
        "&code_challenge_method=S256";
    _actionHelper.openUrl(url);
  }

  openWebSignUp() {
    // TODO Return to app directly if possible https://www.mediawiki.org/wiki/Onboarding_new_Wikipedians/Account_creation_pathways
    String url =
        "https://en.wikipedia.org/w/index.php?title=Special:CreateAccount";
    _actionHelper.openUrl(url);
  }

  openMediaAccount(String username) {
    String url =
        "https://commons.wikimedia.org/w/index.php?title=Special:ListFiles/$username";
    _actionHelper.openUrl(url);
  }

  Future<Userdata> getTokens(String authCode) async {
    // Resources: https://api.wikimedia.org/wiki/Documentation/Getting_started/Authentication#User_authentication
    Future<http.Response> response = http.post(
        Uri.parse('$wikimediaRest/oauth2/access_token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        },
        body: <String, String>{
          'grant_type': 'authorization_code',
          'code': authCode,
          'client_id': clientID,
          'client_secret': await ActionHelper().getClientSecret(),
          'code_verifier': codeVerifier
        });

    var responseData = await response;
    if (responseData.statusCode == 200) {
      var responseJson = json.decode(responseData.body);
      Userdata data = Userdata(
          refreshToken: responseJson['refresh_token'],
          accessToken: responseJson['access_token']);
      return data;
    } else {
      throw RequestException("Error while getting Auth Token.", responseData);
    }
  }

  Future<Userdata?> refreshAccessToken() async {
    Userdata? userdata = await getUserInformationFromFile();
    if (userdata == null || userdata.refreshToken == "") {
      throw ("Tried to refresh access token but userdata.refreshToken is null or empty.");
    } else {
      Future<http.Response> response = http.post(
          Uri.parse('$wikimediaRest/oauth2/access_token'),
          headers: <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          },
          body: <String, String>{
            'grant_type': 'refresh_token',
            'refresh_token': userdata.refreshToken,
            'client_id': clientID,
            'client_secret': await ActionHelper().getClientSecret()
          });
      var responseData = await response;
      if (responseData.statusCode == 200) {
        var responseJson = json.decode(responseData.body);
        Userdata data = Userdata(
            accessToken: responseJson['access_token'],
            refreshToken: responseJson['refresh_token']);
        return data;
      } else if (responseData.statusCode == 401) {
        // When refresh token is revoked
        return null;
      } else {
        throw RequestException(
            "Error while refreshing Access Token.", responseData);
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
    _writeToFile(credentialsFile, data.toJson());
  }

  Future<Userdata?> getUserInformationFromFile() async {
    String jsonString = await _readFromFile(credentialsFile);
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
        Uri.parse('$wikimediaRest/oauth2/resource/profile'),
        headers: <String, String>{
          'Authorization': 'Bearer ${data.accessToken}',
        },
      );
      var responseJson = await response;
      var responseData = json.decode(responseJson.body);
      if (responseJson.statusCode == 200) {
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
        throw RequestException(
            "Error while getting User Info from API.", responseData);
      }
    } else {
      throw (Exception("Access Token is empty"));
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
    if (!(await file.exists())) {
      await _writeToFile(dir, "");
    }
    return file.readAsString();
  }

  _deleteUserDataInFile() async {
    await _writeToFile(credentialsFile, "");
  }

  String _generateCodeVerifier() {
    int length = 70; // Length of the string
    var random = Random.secure();
    var values = List<int>.generate(length, (i) => random.nextInt(255));
    return base64UrlEncode(values).replaceAll("=", "");
  }

  String _encryptCodeVerifier(String codeVerifier) {
    var hash = sha256.convert(ascii.encode(codeVerifier));
    return base64Url
        .encode(hash.bytes)
        .replaceAll("=", "")
        .replaceAll("+", "-")
        .replaceAll("/", "_")
        .replaceAll("+", "-")
        .replaceAll("/", "-");
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
    return Userdata(
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
