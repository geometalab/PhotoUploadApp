import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projects/fragments/settingsFragment.dart';
import 'package:projects/fragments/singlePage/successfulLogin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class LoginHandler {

  static const CLIENT_KEY = "f99a469a26bd7ae8f1d32bef1fa38cb3";

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
    String url = "https://meta.wikimedia.org/w/rest.php/oauth2/authorize?client_id=$CLIENT_KEY&response_type=code";
    _openURL(url);
  }

  Future<String> getUsername() async {
    return await _readMemory('username');
  }

  void listenDeepLinkData(BuildContext context) async {
    FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey("code")) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SuccessfulLogin(data["code"]), fullscreenDialog: true));
        print(data.values);
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print('${platformException.code} - ${platformException.message} ay ay'); // TODO remove "ay ay"
    });
  }

}

