import 'package:flutter/material.dart';
import '../setting_fragment.dart';

class SimpleSettingsPage extends StatelessWidget {
  const SimpleSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: const SettingsFragment());
  }
}
