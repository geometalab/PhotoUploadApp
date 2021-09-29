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

class LoginHandler {

  // Making class a singleton
  static final LoginHandler _loginHandler = LoginHandler._internal();
  factory LoginHandler(){
    return _loginHandler;
  }
  LoginHandler._internal();

  static const CLIENT_ID = "f99a469a26bd7ae8f1d32bef1fa38cb3";

  Future<String> _readMemory(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "0";
  }

  Future<void> _openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  openWebLogin() {
    String url = "https://meta.wikimedia.org/w/rest.php/oauth2/authorize?client_id=$CLIENT_ID&response_type=code";
    _openURL(url);
  }

  _writeMemory(String key, String value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(key, value);
    });
  }

  Future<String> getUsername() async {
    return await _readMemory('username');
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
      print(response.body);
    });
  }
}



