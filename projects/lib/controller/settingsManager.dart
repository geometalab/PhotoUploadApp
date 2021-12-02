import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static late SharedPreferences _prefs;

  // Keys for different SharedPreferences settings
  final String backGroundImageKey = "backgroundImage";
  final String cachedCategoriesKey = "cachedCategories";
  final String simpleModeKey = "easyMode";

  SettingsManager() {
    initPrefs();
  }

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  setBackgroundImage(String path) {
    _prefs.setString(backGroundImageKey, path);
  }

  String? getBackgroundImage() {
    return _prefs.getString(backGroundImageKey);
  }

  addToCachedCategories(String category) {
    List<String> list =
        _prefs.getStringList(cachedCategoriesKey) ?? List.empty(growable: true);
    while (list.length > 4) {
      list.removeLast();
    }
    if (!list.contains(category)) {
      // Only add if this isn't already added
      if (list.length > 3) {
        list.removeAt(0);
      }
      list.add(category);
    } else {
      // Else move category to first
      list.remove(category);
      list.add(category);
    }
    _prefs.setStringList(cachedCategoriesKey, list);
  }

  // TODO cached categories do not display an image
  // TODO give option to delete cached categories
  List<String>? getCachedCategories() {
    List<String>? returnList = _prefs.getStringList(cachedCategoriesKey);
    if (returnList != null) {
      return List.from(
          returnList.reversed); // Reverse so newest entry is displayed first
    }
  }

  setSimpleMode(bool simpleMode) {
    _prefs.setBool(simpleModeKey, simpleMode);
  }

  bool isSimpleMode() {
    bool? simpleMode = _prefs.getBool(simpleModeKey);
    // If simple mode is not set, use a precautionary true
    if (simpleMode == null) {
      simpleMode = true;
      setSimpleMode(true);
    }
    return simpleMode;
  }
}
