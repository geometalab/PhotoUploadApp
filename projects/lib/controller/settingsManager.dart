import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static late SharedPreferences prefs;
  final String backGroundImageKey = "backgroundImage";
  final String cachedCategoriesKey = "cachedCategories";

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

  addToCachedCategories(String category) {
    List<String> list =
        prefs.getStringList(cachedCategoriesKey) ?? List.empty(growable: true);
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
    prefs.setStringList(cachedCategoriesKey, list);
  }

  // TODO cached categories do not display an image
  // TODO give option to delete cached categories
  List<String>? getCachedCategories() {
    List<String>? returnList = prefs.getStringList(cachedCategoriesKey);
    if (returnList != null) {
      return List.from(
          returnList.reversed); // Reverse so newest entry is displayed first
    }
  }
}
