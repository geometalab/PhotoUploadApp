import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginHandler {

  Future<String> _readMemory(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "0";
  }

  Future<String> getUsername() async {
    return await _readMemory('username');
  }

  Future<void> openURL(String url) async {
    if (await canLaunch(url)){
      await launch(url);
    }else{
      throw "Could not launch $url";
    }
  }

}
