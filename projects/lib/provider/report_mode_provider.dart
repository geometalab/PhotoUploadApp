import 'package:catcher/catcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ReportModeProvider extends ChangeNotifier {
  CustomReportMode? _customReportMode;
  final SentryClient _sentryClient;

  ReportModeProvider(this._sentryClient);

  CustomReportMode? getCustomReportMode() => _customReportMode;

  setCustomReportMode(CustomReportMode value) {
    _customReportMode = value;
    notifyListeners();
  }

  CatcherOptions getReleaseConfig(CustomReportMode reportMode) {
    switch (reportMode) {
      case CustomReportMode.dialog:
        return CatcherOptions(DialogReportMode(), [
          SentryHandler(_sentryClient)
        ], localizationOptions: [
          LocalizationOptions("en",
              dialogReportModeDescription:
                  "Unexpected error occurred in application. Click Accept to send error report or Cancel to dismiss report. Go to settings to set how errors should be handled.")
        ]);
      case CustomReportMode.silent:
        return CatcherOptions(
            SilentReportMode(), [SentryHandler(_sentryClient)]);
      case CustomReportMode.none:
        return CatcherOptions(SilentReportMode(), []);
      default:
        throw ("Fallthrough case. Value: $_customReportMode");
    }
  }

  CatcherOptions getDebugConfig(CustomReportMode reportMode) {
    switch (reportMode) {
      case CustomReportMode.dialog:
        return CatcherOptions(DialogReportMode(), [ConsoleHandler()]);
      case CustomReportMode.silent:
        return CatcherOptions(SilentReportMode(), [ConsoleHandler()]);
      case CustomReportMode.none:
        return CatcherOptions(SilentReportMode(), []);
      default:
        throw ("Fallthrough case. Value: $_customReportMode");
    }
  }
}

enum CustomReportMode { silent, dialog, none }
