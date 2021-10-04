import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projects/api/connectionStatus.dart';
import 'package:projects/api/deepLinkListener.dart';
import 'package:projects/api/lifeCycleEventHandler.dart';
import 'package:projects/api/loginHandler.dart';
import 'package:projects/fragments/homeFragment.dart';
import 'package:projects/fragments/commonsUploadFragment.dart';
import 'package:projects/fragments/settingsFragment.dart';
import 'package:projects/fragments/singlePage/noConnection.dart';
import 'package:projects/fragments/userFragment.dart';
import 'package:projects/fragments/mapViewFragment.dart';

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
    DeepLinkListener _deepLinkListener =
        DeepLinkListener(); // Listen to redirect events from a web link

    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);

    LoginHandler()
        .checkCredentials(); // Get user information if user has logged in on this device

    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance!.addObserver(// setState(){} on appResumed
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
      print(isOffline);
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
        return new SelectImageFragment();
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

    if (true) {
      // If no network connection is detected, display this message
          return NoConnection().screen(context);
    } else {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.drawerItems[_selectedDrawerIndex].title),
        ),
        drawer: new Drawer(
          child: new Column(
            children: <Widget>[
              // TODO DrawerMenu header (maybe display wikimedia account when logged in)
              DrawerHeader(child: Text("TODO: Header")),
              new Column(children: drawerOptions)
            ],
          ),
        ),
        body: _getDrawerItemWidget(_selectedDrawerIndex),
      );
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<StreamSubscription>(
        '_connectionChangeStream', _connectionChangeStream));
  }
}
