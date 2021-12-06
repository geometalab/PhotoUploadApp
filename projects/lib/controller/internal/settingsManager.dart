import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static late SharedPreferences _prefs;

  // Keys for different SharedPreferences settings
  final String _backGroundImageKey = "backgroundImage";
  final String _cachedCategoriesKey = "cachedCategories";
  final String _simpleModeKey = "easyMode";

  SettingsManager() {
    initPrefs();
  }

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  setBackgroundImage(String path) {
    _prefs.setString(_backGroundImageKey, path);
  }

  String? getBackgroundImage() {
    return _prefs.getString(_backGroundImageKey);
  }

  addToCachedCategories(Map<String, dynamic> category) {
    List<String> list = _prefs.getStringList(_cachedCategoriesKey) ??
        List.empty(growable: true);
    while (list.length > 4) {
      list.removeLast();
    }
    if (!list.any(
        (element) => (json.decode(element))['title'] == category['title'])) {
      // Only add if this isn't already added
      if (list.length > 3) {
        list.removeAt(0);
      }
      list.add(json.encode(category));
    } else {
      // Else move category to first
      list.removeWhere(
          (element) => (json.decode(element))['title'] == category['title']);
      list.add(json.encode(category));
    }
    _prefs.setStringList(_cachedCategoriesKey, list);
  }

  // TODO cached categories do not display an image
  // TODO give option to delete cached categories
  List<Map<String, dynamic>>? getCachedCategories() {
    // _prefs.remove(_cachedCategoriesKey);
    List<String>? tempList = _prefs.getStringList(_cachedCategoriesKey);
    List<Map<String, dynamic>>? returnList = List.empty(growable: true);
    if (tempList == null) {
      return null;
    }
    for (String value in tempList) {
      returnList.add(json.decode(value));
    }
    return List.from(
        returnList.reversed); // Reverse so newest entry is displayed first
  }

  setSimpleMode(bool simpleMode) {
    _prefs.setBool(_simpleModeKey, simpleMode);
  }

  bool isSimpleMode() {
    bool? simpleMode = _prefs.getBool(_simpleModeKey);
    // If simple mode is not set, use a precautionary true
    if (simpleMode == null) {
      simpleMode = true;
      setSimpleMode(true);
    }
    return simpleMode;
  }
}
