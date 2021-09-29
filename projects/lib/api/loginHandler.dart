import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:projects/fragments/singlePage/successfulLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:path_provider/path_provider.dart';

// TODO Cover access token expiry after 4h and maybe refresh token expiry after a year

class LoginHandler {
  static const CLIENT_ID = "f99a469a26bd7ae8f1d32bef1fa38cb3";
  static const CREDENTIALS_FILE = "credentials.json";

  Userdata userdata = Userdata();

  // Making class a singleton
  static final LoginHandler _loginHandler = LoginHandler._internal();
  factory LoginHandler(){
    return _loginHandler;
  }
  LoginHandler._internal();

  checkCredentials() async{
    try{
      String jsonString = await _readFromFile(CREDENTIALS_FILE);
      userdata = Userdata().fromJson(jsonString);
      refreshAccessToken();
    }catch(e){
      print("Could not check Credentials successfully. Error: " + e.toString());
    }
  }

  openWebLogin() {
    String url = "https://meta.wikimedia.org/w/rest.php/oauth2/authorize?client_id=$CLIENT_ID&response_type=code";
    _openURL(url);
  }

  getAccessToken(String authCode) async {
    // Resources: https://api.wikimedia.org/wiki/Documentation/Getting_started/Authentication#User_authentication

    await dotenv.load(fileName: ".env");
    String? clientSecret = dotenv.env['SECRET_TOKEN']; // Get the secret token from the local .env file
    if(clientSecret == null){
      throw("Secret token is not provided in .env");
    }

    Future<http.Response> response = http.post(
        Uri.parse('https://meta.wikimedia.org/w/rest.php/oauth2/access_token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
        },
        body: <String, String>{
          'grant_type': 'authorization_code',
          'code': authCode,
          'client_id': CLIENT_ID,
          'client_secret': clientSecret,
        }
    );
    
    response.then((response) {
      var responseData = json.decode(response.body);
      print(responseData['access_token']);
    });
  }

  refreshAccessToken(){

    throw UnimplementedError;
  }

  saveUserData(Userdata data){
    _writeToFile(CREDENTIALS_FILE, data.toJson());
  }

  Future<Userdata?> getUserInformation() async {
    String jsonString = await _readFromFile(CREDENTIALS_FILE);
    return Userdata().fromJson(jsonString);
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

}

class Userdata {
  String username;
  String email;
  int editCount;
  String accessToken;
  String refreshToken;

  Userdata({this.username = "", this.email = "", this.editCount = 0, this.accessToken = "", this.refreshToken = ""});

  Userdata fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    return new Userdata(
        username: json['username'],
        accessToken: json['accessToken'],
        refreshToken: json['refreshToken'],
        email: json['email'],
        editCount: int.parse(json['editCount'])
    );

  }

  String toJson(){
    return jsonEncode(_toMap());
  }

  Map<String, dynamic> _toMap(){
    return {
      'username': username,
      'email': email,
      'editCount': editCount.toString(),
      'accessToken': accessToken,
      'refreshToken': refreshToken
    };
  }


}


