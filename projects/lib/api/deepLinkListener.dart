import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'loginHandler.dart';

// Listens to when app is opened with a deeplink (atm only when user logged into wikimedia)
// Also gets the code for further authentication process
class DeepLinkListener extends ChangeNotifier {
  DeepLinkListener() {
    listenDeepLinkData();
  }

  void listenDeepLinkData() async {
    FlutterBranchSdk.initSession().listen((listenerData) async {
      if (listenerData.containsKey("code")) {
        Userdata userData =
            await LoginHandler().getTokens(listenerData["code"]);
        userData = await LoginHandler().getUserInformationFromAPI(userData);
        await LoginHandler().saveUserDataToFile(userData);
        notifyListeners();
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      print('${platformException.code} - ${platformException.message}');
    });
  }
}
