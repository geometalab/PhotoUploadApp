import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart' as assertions;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/connectionStatus.dart';
import 'package:projects/controller/lifeCycleEventHandler.dart';
import 'package:projects/controller/loginHandler.dart';
import 'package:projects/controller/pictureOfTheDayService.dart';
import 'package:projects/controller/settingsManager.dart';
import 'package:projects/view/homeFragment.dart';
import 'package:projects/view/commonsUploadFragment.dart';
import 'package:projects/view/settingsFragment.dart';
import 'package:projects/view/singlePage/noConnection.dart';
import 'package:projects/view/userFragment.dart';
import 'package:projects/view/mapViewFragment.dart';
import 'package:projects/style/textStyles.dart';
import 'package:projects/style/userAvatar.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class DrawerItem {
  String title;
  IconData? icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  final drawerItems = [
    new DrawerItem("Home", Icons.home_filled),
    new DrawerItem("Divider", null),
    new DrawerItem("Upload to Wikimedia", Icons.upload_file),
    new DrawerItem("Find nearby Categories", Icons.map),
    new DrawerItem("Divider", null),
    new DrawerItem("Account Settings", Icons.person),
    new DrawerItem("Divider", null),
    new DrawerItem("Settings", Icons.settings)
  ];

  @override
  State<StatefulWidget> createState() {
    return new _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late StreamSubscription _connectionChangeStream;
  ViewSwitcher viewSwitcher = ViewSwitcher();
  bool isOffline = false;
  int _selectedDrawerIndex = 0;

  @override
  void initState() {
    super.initState();

    ConnectionStatusListener connectionStatus =
        ConnectionStatusListener.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
    connectionStatus.checkConnection().then((value) => connectionChanged(
        connectionStatus.hasConnection)); // For check on startup

    // For sharing images coming from outside the app while the app is in the memory
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        processExternalIntent(value);
      });
    }, onError: (err) {
      throw ("getIntentDataStream error: $err");
    });

    // For sharing images coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        processExternalIntent(value);
      });
    });

    PictureOfTheDayService().getPictureOfTheDay(); // Preload POTD

    LoginHandler()
        .checkCredentials(); // Get user info if there is a login on this device

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
        return new HomeFragment();
      case 2:
        return new CommonsUploadFragment();
      case 3:
        return new MapFragment();
      case 5:
        return new UserFragment();
      case 7:
        return new SettingsFragment();
      default:
        return new Text(
            "Widget could not be returned for _getDrawerItemWidget");
    }
  }

  onSelectItem(int index) {
    _selectedDrawerIndex = index;
    Navigator.of(context).pop();
  }

  // Gets called when a external intent is received
  processExternalIntent(List<SharedMediaFile> sharedMediaList) {
    if (sharedMediaList.isNotEmpty) {
      // Clear the information collector and add the passed data
      InformationCollector ic = InformationCollector();
      ic.clear();
      ic.image = XFile(sharedMediaList.first.path);

      // Close all routes in case one is open
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Switch to the upload menu
      Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    _selectedDrawerIndex =
        Provider.of<ViewSwitcher>(context, listen: false).viewIndex;
    // TODO "settings" menu tile at bottom
    List<Widget> drawerOptions = [];
    for (var i = 0; i < widget.drawerItems.length; i++) {
      var d = widget.drawerItems[i];
      if (d.title == "Divider") {
        drawerOptions.add(new Divider());
      } else {
        drawerOptions.add(new ListTile(
            leading: new Icon(d.icon),
            title: new Text(d.title),
            selected: i == _selectedDrawerIndex,
            onTap: () {
              Navigator.of(context).pop();
              Provider.of<ViewSwitcher>(context, listen: false).viewIndex = i;
            }));
      }
    }

    if (isOffline) {
      // If no network connection is detected, display this message
      return NoConnection();
    } else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
        ),
        drawer: new Drawer(
          child: new Column(
            children: <Widget>[drawerHeader(), Column(children: drawerOptions)],
          ),
        ),
        body: _getDrawerItemWidget(
            Provider.of<ViewSwitcher>(context, listen: true).viewIndex),
      );
    }
  }

  Widget drawerHeader() {
    return FutureBuilder(
      future: LoginHandler().getUserInformationFromFile(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return DrawerHeader(
            child: Container(
              color: Theme.of(context).colorScheme.primary,
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Text(
                      "Not logged into wikimedia",
                      style: headerText.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  )
                ],
              ),
            ),
            padding: EdgeInsets.zero,
          );
        } else {
          SettingsManager sm = SettingsManager();
          Userdata data = snapshot.data;
          Decoration? decoration;
          String? imagePath = sm.getBackgroundImage();
          if (imagePath == null) {
            imagePath = SettingsFragment().assetImages()[0];
            sm.setBackgroundImage(imagePath);
          }
          if (imagePath.isNotEmpty) {
            decoration = BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                image: AssetImage(imagePath),
              ),
            );
          } else {
            decoration = BoxDecoration(
                color: Theme.of(context).colorScheme.primaryVariant);
          }
          return UserAccountsDrawerHeader(
              decoration: decoration,
              currentAccountPicture: UserAvatar(),
              currentAccountPictureSize: Size.square(48),
              // arrowColor: Theme.of(context).colorScheme.onPrimary,
              // onDetailsPressed: () { }, // TODO maybe put something in this dropdown
              accountName: Text(data.username),
              accountEmail: Text(data.email));
        }
      },
    );
  }

  @override
  void debugFillProperties(assertions.DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(assertions.DiagnosticsProperty<StreamSubscription>(
        '_connectionChangeStream', _connectionChangeStream));
  }
}

class ViewSwitcher extends ChangeNotifier {
  int _viewIndex = 0;

  int get viewIndex {
    return _viewIndex;
  }

  set viewIndex(int viewIndex) {
    _viewIndex = viewIndex;
    notifyListeners();
  }
}
