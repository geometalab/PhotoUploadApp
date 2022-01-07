import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/view/simpleUpload/simpleUserPage.dart';
import 'package:provider/provider.dart';
import '../../pageContainer.dart';
import '../wiki/loginHandler.dart';

// TODO if one of the requests in the login process fails, display error (or at least acknowledge it)

// Listens to when app is opened with a deeplink (atm only when user logged into wikimedia)
// Also gets the code for further authentication process
class DeepLinkListener extends ChangeNotifier {
  void listenDeepLinkData(BuildContext context) async {
    FlutterBranchSdk.initSession().listen((listenerData) async {
      if (listenerData.containsKey("code")) {
        // Close all routes in case one is open
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Display loading indicator
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator.adaptive(),
              );
            },
          ),
        );

        // Process the received auth code
        await LoginHandler().processAuthCode(listenerData["code"]);
        notifyListeners();

        // Pop loading indicator
        Navigator.pop(context);

        // Switch to user menu for simple or normal mode
        if (SettingsManager().isSimpleMode()) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => SimpleUsersPage(),
            ),
          );
        } else {
          Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 5;
        }
      }
    }, onError: (error) {
      PlatformException platformException = error as PlatformException;
      throw ('${platformException.code} - ${platformException.message}');
    });
  }
}
