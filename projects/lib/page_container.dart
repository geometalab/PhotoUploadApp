import 'dart:async';
import 'package:flutter/foundation.dart' as assertions;
import 'package:flutter/material.dart';
import 'package:projects/controller/eventHandler/connection_status.dart';
import 'package:projects/controller/eventHandler/deeplink_listener.dart';
import 'package:projects/controller/eventHandler/external_intent_handler.dart';
import 'package:projects/controller/eventHandler/lifecycle_event_handler.dart';
import 'package:projects/controller/wiki/login_handler.dart';
import 'package:projects/controller/wiki/picture_of_the_day_service.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import 'package:projects/model/datasets.dart';
import 'package:projects/provider/view_switcher.dart';
import 'package:projects/view/home_fragment.dart';
import 'package:projects/view/commons_upload_fragment.dart';
import 'package:projects/view/setting_fragment.dart';
import 'package:projects/view/simpleUpload/simple_homepage.dart';
import 'package:projects/view/singlePage/introduction_view.dart';
import 'package:projects/view/singlePage/no_connection_view.dart';
import 'package:projects/view/user_fragment.dart';
import 'package:projects/view/map_view_fragment.dart';
import 'package:projects/style/user_avatar.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class DrawerItem {
  final String title;
  final IconData? icon;
  const DrawerItem(this.title, this.icon);
}

class PageContainer extends StatefulWidget {
  static const drawerItems = [
    DrawerItem("Home", Icons.home_filled),
    DrawerItem("Divider", null),
    DrawerItem("Upload to Wikimedia", Icons.upload_file),
    DrawerItem("Find nearby Categories", Icons.map),
    DrawerItem("Divider", null),
    DrawerItem("Account Settings", Icons.person),
    DrawerItem("Divider", null),
    DrawerItem("Settings", Icons.settings)
  ];

  const PageContainer({assertions.Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PageContainerState();
}

class _PageContainerState extends State<PageContainer> {
  late StreamSubscription _connectionChangeStream;
  ViewSwitcher viewSwitcher = ViewSwitcher();
  bool isOffline = false;
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();

    // Listen to a connection change
    ConnectionStatusListener connectionStatus =
        ConnectionStatusListener.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    // For check on startup
    connectionStatus
        .checkConnection()
        .then((value) => connectionChanged(connectionStatus.hasConnection));

    // For sharing images coming from outside the app while the app is in the memory
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        ExternalIntentHandler().processExternalIntent(value, context);
      });
    });

    // Begin listening to deeplink redirects
    DeepLinkListener().listenDeepLinkData(context);

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        ExternalIntentHandler().processExternalIntent(value, context);
      });
    });

    // Preload POTD
    PictureOfTheDayService().getPictureOfTheDay();

    // Get user info if there is a login on this device
    LoginHandler().checkCredentials();

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance!.addObserver(// setState(){ } on appResumed
        LifecycleEventHandler(resumeCallBack: () async {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    super.dispose();
    _connectionChangeStream.cancel();
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return const HomeFragment();
      case 2:
        return const CommonsUploadFragment();
      case 3:
        return const MapFragment();
      case 5:
        return const UserFragment();
      case 7:
        return const SettingsFragment();
      default:
        return const Text(
            "Widget could not be returned for _getDrawerItemWidget");
    }
  }

  onSelectItem(int index) {
    _selectedDrawerIndex = index;
    Navigator.of(context).pop();
  }

  bool willPop(BuildContext context) {
    // Pops (closes the app) only if we are in home
    if (Provider.of<ViewSwitcher>(context, listen: false).viewIndex == 0) {
      return true;
    } else {
      // else returns user to home
      Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 0;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    int viewIndex = Provider.of<ViewSwitcher>(context, listen: true).viewIndex;
    SettingsManager settingsManager = SettingsManager();

    introductionView(settingsManager);
    if (isOffline) {
      return const NoConnection();
    }
    if (settingsManager.isSimpleMode()) {
      return const SimpleHomePage();
    } else {
      // Create Drawer
      _selectedDrawerIndex =
          Provider.of<ViewSwitcher>(context, listen: false).viewIndex;
      // TODO "settings" menu tile at bottom
      List<Widget> drawerOptions = [];
      for (var i = 0; i < PageContainer.drawerItems.length; i++) {
        var d = PageContainer.drawerItems[i];
        if (d.title == "Divider") {
          drawerOptions.add(const Divider());
        } else {
          drawerOptions.add(ListTile(
              leading: Icon(d.icon),
              title: Text(d.title),
              selected: i == _selectedDrawerIndex,
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<ViewSwitcher>(context, listen: false).viewIndex = i;
              }));
        }
      }
      return WillPopScope(
        onWillPop: () async {
          return willPop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(PageContainer.drawerItems[_selectedDrawerIndex].title),
          ),
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                _drawerHeader(),
                Column(children: drawerOptions)
              ],
            ),
          ),
          body: _getDrawerItemWidget(viewIndex),
        ),
      );
    }
  }

  Widget _drawerHeader() {
    return FutureBuilder(
      future: LoginHandler().getUserInformationFromFile(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return UserAccountsDrawerHeader(
            decoration: _headerDecorationImage(),
            currentAccountPictureSize: const Size.square(48),
            currentAccountPicture: const UserAvatar(Icons.person_off),
            accountEmail: const Text("Log in to upload images."),
            accountName: const Text("Not logged in"),
          );
        } else {
          Userdata data = snapshot.data;
          return UserAccountsDrawerHeader(
              decoration: _headerDecorationImage(),
              currentAccountPicture:
                  const UserAvatar(Icons.person_outline_rounded),
              currentAccountPictureSize: const Size.square(48),
              // arrowColor: Theme.of(context).colorScheme.onPrimary,
              // onDetailsPressed: () { }, // TODO maybe put something in this dropdown
              accountName: Text(data.username),
              accountEmail: Text(data.email));
        }
      },
    );
  }

  Decoration _headerDecorationImage() {
    SettingsManager sm = SettingsManager();
    String? imagePath = sm.getBackgroundImage();
    if (imagePath == null) {
      imagePath = assetImages()[0];
      sm.setBackgroundImage(imagePath);
    }
    if (imagePath.isNotEmpty) {
      return BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
          image: AssetImage(imagePath),
        ),
      );
    } else {
      return BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer);
    }
  }

  @override
  void debugFillProperties(assertions.DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(assertions.DiagnosticsProperty<StreamSubscription>(
        '_connectionChangeStream', _connectionChangeStream));
  }

  introductionView(SettingsManager settingsManager) {
    Future.delayed(const Duration(milliseconds: 700), () {
      if (settingsManager.isFirstTime()) {
        // Only push the IntroductionView() if current route is home page, else do nothing
        if (!Navigator.canPop(context)) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => const IntroductionView(),
            ),
          );
        }
      }
    });
  }
}
