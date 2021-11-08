import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projects/api/connectionStatus.dart';
import 'package:projects/api/lifeCycleEventHandler.dart';
import 'package:projects/api/loginHandler.dart';
import 'package:projects/api/pictureOfTheDayService.dart';
import 'package:projects/fragments/homeFragment.dart';
import 'package:projects/fragments/commonsUploadFragment.dart';
import 'package:projects/fragments/settingsFragment.dart';
import 'package:projects/fragments/singlePage/noConnection.dart';
import 'package:projects/fragments/userFragment.dart';
import 'package:projects/fragments/mapViewFragment.dart';
import 'package:projects/style/textStyles.dart';
import 'package:projects/style/userAvatar.dart';

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
    new DrawerItem("Find nearby Categories", Icons.add_location_outlined),
    new DrawerItem("Divider", null),
    new DrawerItem("Account Settings", Icons.person),
    new DrawerItem("Divider", null),
    new DrawerItem("Settings", Icons.settings)
  ];

  @override
  State<StatefulWidget> createState() {
    return new HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  late StreamSubscription _connectionChangeStream;
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

  void refresh() {
    setState(() {});
  }

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new HomeFragment();
      case 2:
        return new CommonsUploadFragment();
      case 3:
        return new StatefulMapFragment();
      case 5:
        return new UserFragment();
      case 7:
        return new SettingsFragment();
      default:
        return new Text(
            "Widget could not be returned for _getDrawerItemWidget");
    }
  }

  _onSelectItem(int index) {
    setState(() => _selectedDrawerIndex = index);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
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
          onTap: () => _onSelectItem(i),
        ));
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
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      );
    }
  }

  Widget drawerHeader() {
    return FutureBuilder(
      // TODO this gets the info before it is written to file in case of login, resulting in the drawer staying in the wrong state for one refresh
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
          Userdata data = snapshot.data;
          return UserAccountsDrawerHeader(
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
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<StreamSubscription>(
        '_connectionChangeStream', _connectionChangeStream));
  }
}
