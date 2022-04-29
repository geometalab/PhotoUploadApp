import 'package:flutter/material.dart';
import '../settingsFragment.dart';

class SimpleSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: const SettingsFragment());
  }
}
