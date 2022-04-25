import 'dart:async';
import 'package:flutter/foundation.dart' as assertions;
import 'package:flutter/material.dart';
import 'package:projects/controller/eventHandler/connectionStatus.dart';
import 'package:projects/controller/eventHandler/deepLinkListener.dart';
import 'package:projects/controller/eventHandler/externalIntentHandler.dart';
import 'package:projects/controller/eventHandler/lifeCycleEventHandler.dart';
import 'package:projects/controller/wiki/loginHandler.dart';
import 'package:projects/controller/wiki/pictureOfTheDayService.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/model/datasets.dart';
import 'package:projects/view/homeFragment.dart';
import 'package:projects/view/commonsUploadFragment.dart';
import 'package:projects/view/settingsFragment.dart';
import 'package:projects/view/simpleUpload/simpleHomePage.dart';
import 'package:projects/view/singlePage/introductionView.dart';
import 'package:projects/view/singlePage/noConnection.dart';
import 'package:projects/view/userFragment.dart';
import 'package:projects/view/mapViewFragment.dart';
import 'package:projects/style/textStyles.dart' as customStyles;
import 'package:projects/style/userAvatar.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class DrawerItem {
  String title;
  IconData? icon;
  DrawerItem(this.title, this.icon);
}

class PageContainer extends StatefulWidget {
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
      return NoConnection();
    }
    if (settingsManager.isSimpleMode()) {
      return SimpleHomePage();
    } else {
      // Create Drawer
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
      return WillPopScope(
        onWillPop: () async {
          return willPop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.drawerItems[_selectedDrawerIndex].title),
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
          return DrawerHeader(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Stack(
                children: [
                  Positioned(
                      left: 16,
                      bottom: 16,
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_off,
                            color: Colors.white,
                          ),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                          Text(
                            "Not logged into wikimedia",
                            style: customStyles.objectDescription
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ))
                ],
              ),
              decoration: _headerDecorationImage(),
            ),
            padding: EdgeInsets.zero,
          );
        } else {
          Userdata data = snapshot.data;
          return UserAccountsDrawerHeader(
              decoration: _headerDecorationImage(),
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
          colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          image: AssetImage(imagePath),
        ),
      );
    } else {
      return BoxDecoration(color: Theme.of(context).colorScheme.primaryVariant);
    }
  }

  @override
  void debugFillProperties(assertions.DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(assertions.DiagnosticsProperty<StreamSubscription>(
        '_connectionChangeStream', _connectionChangeStream));
  }

  introductionView(SettingsManager settingsManager) {
    Future.delayed(Duration(milliseconds: 700), () {
      if (settingsManager.isFirstTime()) {
        // Only push the IntroductionView() if current route is home page, else do nothing
        if (!Navigator.canPop(context)) {
          Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
              builder: (BuildContext context) => IntroductionView(),
            ),
          );
        }
      }
    });
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
