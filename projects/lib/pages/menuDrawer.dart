import 'package:flutter/material.dart';
import 'package:projects/fragments/homeFragment.dart';
import 'package:projects/fragments/commonsUploadFragment.dart';
import 'package:projects/fragments/settingsFragment.dart';
import 'package:projects/fragments/userFragment.dart';
import 'package:projects/fragments/mapViewFragment.dart';


class DrawerItem {
  String title;
  IconData? icon;
  DrawerItem(this.title, this.icon);
}

class HomePage extends StatefulWidget {
  final  drawerItems = [
    new DrawerItem("Home", Icons.not_started_outlined),
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
  int _selectedDrawerIndex = 0;

  _getDrawerItemWidget(int pos) {
    switch (pos) {
      case 0:
        return new HomeFragment();
      case 1:
        return new SelectImageFragment();
      case 2:
        return new StatefulMapFragment();
      case 4:
        return new UserFragment();
      case 6:
        return new SettingsFragment();

      default:
        return new Text("Error");
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
      if(d.title == "Divider"){
        drawerOptions.add(new Divider());
      }else{
        drawerOptions.add(
            new ListTile(
              leading: new Icon(d.icon),
              title: new Text(d.title),
              selected: i == _selectedDrawerIndex,
              onTap: () => _onSelectItem(i),
            )
        );
      }
    }
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