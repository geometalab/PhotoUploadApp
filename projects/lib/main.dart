import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:projects/style/themes.dart' as customThemes;
import 'api/connectionStatus.dart';

// TODO Improve look & feel
// TODO create a Logo
// TODO find a name
// TODO Image caching and maybe other network traffic optimisations
// TODO Responsive design for tablets (and landscape mode?)
// TODO Licensing
// TODO images don't load in browser
// TODO make branch reroute page more beautiful (e.g. "Return to App" button & "Login successful" text)

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the connection listener
  ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton
      .getInstance();
  connectionStatus.initialize();

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
