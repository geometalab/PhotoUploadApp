import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/pageContainer.dart';
import 'package:projects/style/themes.dart' as customThemes;
import 'package:provider/provider.dart';
import 'controller/eventHandler/connectionStatus.dart';
import 'package:flutter/services.dart';

// TODO make branch reroute page more beautiful (e.g. "Return to App" button & "Login successful" text)
// TODO add editing of your own media
// TODO add "featured images" article on homepage
// TODO allow custom categories, but are you sure prompt
// TODO add gps coordinates from exif header if available
// TODO Guide to licences article

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
        title: 'Commons Uploader',
        debugShowCheckedModeBanner: false,
        theme: customThemes.lightTheme,
        darkTheme: customThemes.darkTheme,
        themeMode: EasyDynamicTheme.of(context).themeMode,
        home: PageContainer(),
      ),
    );
  }
}
