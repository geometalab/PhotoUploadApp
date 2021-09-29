import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'loginHandler.dart';

class DeepLinkListener{
  DeepLinkListener(){
    listenDeepLinkData();
  }

  void listenDeepLinkData() async {
    FlutterBranchSdk.initSession().listen((data) {
      if (data.containsKey("code")) {
        LoginHandler().getAccessToken(data["code"]);
        print("handler");
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print('${platformException.code} - ${platformException.message}');
    });
  }
}