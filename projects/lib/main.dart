import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:flutter/foundation.dart';

// TODO Improve look & feel
// TODO Implement Warning Messaging when no internet connection
// TODO Look if making map no rotatable is possible/appropriate?
// TODO create a Logo
// TODO find a name
// TODO Image caching and maybe other network traffic optimisations

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NavigationDrawer Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue, // TODO Choose a Color Scheme
      ),
      home: new HomePage(),
    );
  }
}
@override
void initState() {
  // TODO remove once deeplinks are working
  FlutterBranchSdk.validateSDKIntegration();
}
