import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/settingsManager.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:projects/style/themes.dart' as customThemes;
import 'package:provider/provider.dart';
import 'controller/connectionStatus.dart';
import 'package:flutter/services.dart';

// TODO Improve look & feel
// TODO create a Logo
// TODO find a name
// TODO Image caching and maybe other network traffic optimisations
// TODO Responsive design for tablets (and landscape mode?)
// TODO Licensing
// TODO images don't load in browser
// TODO make branch reroute page more beautiful (e.g. "Return to App" button & "Login successful" text)
// TODO add editing of your own media
// TODO add "featured images" article on homepage

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(// Do not allow landscape mode
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  ConnectionStatusListener connectionStatus = ConnectionStatusListener
      .getInstance(); // Initialize the connection listener
  connectionStatus.initialize();

  SettingsManager(); // Initialize shared preferences

  runApp(
    EasyDynamicThemeWidget(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ViewSwitcher())],
      child: MaterialApp(
        title: 'Wikimedia Commons Uploader',
        debugShowCheckedModeBanner: false,
        theme: customThemes.lightTheme,
        darkTheme: customThemes.darkTheme,
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: new HomePage(),
      ),
    );
  }
}
