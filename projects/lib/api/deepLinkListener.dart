import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

import 'loginHandler.dart';

class DeepLinkListener{
  DeepLinkListener(){
    listenDeepLinkData();
  }

  void listenDeepLinkData() async {
    FlutterBranchSdk.initSession().listen((listenerData) async {
      if (listenerData.containsKey("code")) {
        Userdata userData = await LoginHandler().getTokens(listenerData["code"]);
        userData = await LoginHandler().getUserInformationFromAPI(userData);
        LoginHandler().saveUserData(userData);
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print('${platformException.code} - ${platformException.message}');
    });
  }
}