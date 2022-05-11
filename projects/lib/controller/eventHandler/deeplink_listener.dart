import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import 'package:projects/view/simpleUpload/simple_user_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../page_container.dart';
import '../wiki/login_handler.dart';

// TODO if one of the requests in the login process fails, display error (or at least acknowledge it)

// Listens to when app is opened with a deeplink (atm only when user logged into wikimedia)
// Also gets the code for further authentication process
class DeepLinkListener extends ChangeNotifier {
  void listenDeepLinkData(BuildContext context) async {
    FlutterBranchSdk.initSession().listen((listenerData) async {
      if (listenerData.containsKey("code")) {
        // Close browser and all routes in case one is open
        closeInAppWebView();
        while (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Display loading indicator
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
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
              builder: (BuildContext context) => const SimpleUsersPage(),
            ),
          );
        } else {
          Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 5;
        }
        rebuildAllChildren(context); // Father forgive me, for i have sinned.
      }
    }, onError: (error) {
      throw error as PlatformException;
    });
  }

  void rebuildAllChildren(BuildContext context) {
    // I know this is not how you should go about this
    // But it was a 2 min fix so idk
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
  }
}
