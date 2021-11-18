import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static late SharedPreferences prefs;
  final String backGroundImageKey = "backgroundImage";

  SettingsManager() {
    initPrefs();
  }

  initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  setBackgroundImage(String path) {
    prefs.setString(backGroundImageKey, path);
  }

  String? getBackgroundImage() {
    return prefs.getString(backGroundImageKey);
  }
}
