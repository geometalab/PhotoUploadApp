import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:flutter/foundation.dart';


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
@override
void initState() {
  // TODO remove once deeplinks are working
  FlutterBranchSdk.validateSDKIntegration();
}
