import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
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
// TODO Responsive design for tablets (and landscape mode?)
// TODO Licensing
// TODO images don't load in browser

void main() async {
  runApp(
    EasyDynamicThemeWidget(
      child: MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'NavigationDrawer Demo',
      debugShowCheckedModeBanner: false,
      theme: customThemes.lightTheme,
      darkTheme: customThemes.darkTheme,
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: new HomePage(),
    );
  }

  changeTheme() {

  }
}
@override
void initState() {
  // TODO remove once deeplinks are working
  FlutterBranchSdk.validateSDKIntegration();
}
