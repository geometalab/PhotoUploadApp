import 'package:catcher/core/catcher.dart';
import 'package:catcher/handlers/console_handler.dart';
import 'package:catcher/handlers/sentry_handler.dart';
import 'package:catcher/mode/dialog_report_mode.dart';
import 'package:catcher/model/catcher_options.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/pageContainer.dart';
import 'package:projects/style/themes.dart' as customThemes;
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'controller/eventHandler/connectionStatus.dart';
import 'package:flutter/services.dart';

import 'controller/internal/actionHelper.dart';

// TODO make branch reroute page more beautiful (e.g. "Return to App" button & "Login successful" text)
// TODO add editing of your own media
// TODO add "featured images" article on homepage
// TODO allow custom categories, but are you sure prompt
// TODO add gps coordinates from exif header if available
// TODO Guide to licences article
// TODO Handle Main activity destruction (https://pub.dev/packages/image_picker#handling-mainactivity-destruction-on-android)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations(// Do not allow landscape mode
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  ConnectionStatusListener connectionStatus = ConnectionStatusListener
      .getInstance(); // Initialize the connection listener
  connectionStatus.initialize();

  SettingsManager(); // Initialize shared preferences

  // Initialize Sentry for error reporting
  String sentryDsn = await ActionHelper().getSentryDns();
  var sentryOptions = (SentryFlutterOptions options) {
    options.dsn = sentryDsn;
    options.tracesSampleRate = 0.2;
  };
  await SentryFlutter.init(sentryOptions);

  // Catcher options
  CatcherOptions debugOptions =
      CatcherOptions(DialogReportMode(), [ConsoleHandler()]);
  CatcherOptions releaseOptions = CatcherOptions(DialogReportMode(),
      [SentryHandler(SentryClient(SentryOptions(dsn: sentryDsn)))]);

  Catcher(
      rootWidget: EasyDynamicThemeWidget(child: MyApp()),
      debugConfig: debugOptions,
      releaseConfig: releaseOptions);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ViewSwitcher())],
      child: MaterialApp(
        navigatorKey: Catcher.navigatorKey,
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
