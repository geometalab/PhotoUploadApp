import 'package:flutter/material.dart';
import 'package:projects/fragments/homeFragment.dart';
import 'package:projects/fragments/commonsUploadFragment.dart';
import 'package:projects/fragments/settingsFragment.dart';
import 'package:projects/pages/homePage.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NavigationDrawer Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new HomePage(),
    );
  }
}