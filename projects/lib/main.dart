import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:projects/style/themes.dart' as customThemes;

// TODO Improve look & feel
// TODO Implement Warning Messaging when no internet connection
// TODO Look if making map no rotatable is possible/appropriate?
// TODO Block file uploading when not logged in (or better yet, redirect to login screen)
// TODO create a Logo
// TODO find a name
// TODO Image caching and maybe other network traffic optimisations
// TODO Responsive design for tablets (and landscape mode?)
// TODO Licensing
// TODO images don't load in browser
// TODO make branch reroute page more beautiful (e.g. "Return to App" button & "Login successful" text)


void main() async {
WidgetsFlutterBinding.ensureInitialized();
// FlutterBranchSdk.validateSDKIntegration();
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
      title: 'Wikimedia Commons Uploader',
      debugShowCheckedModeBanner: false,
      theme: customThemes.lightTheme,
      darkTheme: customThemes.darkTheme,
      themeMode: EasyDynamicTheme.of(context).themeMode,
      home: new HomePage(),
    );
  }
}

