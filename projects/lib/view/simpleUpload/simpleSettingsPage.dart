import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../settingsFragment.dart';

class SimpleSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Settings"),
        ),
        body: SettingsFragment());
  }
}
