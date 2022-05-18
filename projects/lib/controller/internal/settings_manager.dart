import 'dart:convert';
import 'package:catcher/catcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:projects/provider/report_mode_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static late SharedPreferences _prefs;

  // Keys for different SharedPreferences settings
  final String _backgroundImageKey = "backgroundImage";
  final String _cachedCategoriesKey = "cachedCategories";
  final String _simpleModeKey = "easyMode";
  final String _firstTimeKey = "firstTime";
  final String _reportModeKey = "reportMode";

  SettingsManager() {
    initPrefs();
  }

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  clearPrefs() {
    _prefs.clear().then((value) {
      if (!value) {
        throw ("SharedPreferences could not be cleared");
      }
    });
  }

  setBackgroundImage(String path) {
    _prefs.setString(_backgroundImageKey, path);
  }

  String? getBackgroundImage() {
    return _prefs.getString(_backgroundImageKey);
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

  setFirstTime(bool isFirstTime) {
    _prefs.setBool(_firstTimeKey, isFirstTime);
  }

  bool isFirstTime() {
    if (!_prefs.containsKey(_firstTimeKey)) {
      setFirstTime(true);
    }
    return _prefs.getBool(_firstTimeKey)!;
  }

  CustomReportMode getReportMode(BuildContext context) {
    CustomReportMode? reportMode =
        Provider.of<ReportModeProvider>(context, listen: false)
            .getCustomReportMode();
    if (reportMode != null) {
      return reportMode;
    }
    if (!_prefs.containsKey(_reportModeKey)) {
      switch (_prefs.getString(_reportModeKey)) {
        case "silent":
          {
            return CustomReportMode.silent;
          }
        case "dialog":
          {
            return CustomReportMode.dialog;
          }
        case "none":
          {
            return CustomReportMode.none;
          }
        default:
          {
            return CustomReportMode.dialog;
          }
      }
    } else {
      setReportMode(CustomReportMode.dialog, context);
      return CustomReportMode.dialog;
    }
  }

  setReportMode(CustomReportMode reportMode, BuildContext context) {
    Provider.of<ReportModeProvider>(context, listen: false)
        .setCustomReportMode(reportMode);
    switch (reportMode) {
      case CustomReportMode.dialog:
        _prefs.setString(_reportModeKey, "dialog");
        break;
      case CustomReportMode.silent:
        _prefs.setString(_reportModeKey, "silent");
        break;
      case CustomReportMode.none:
        _prefs.setString(_reportModeKey, "none");
        break;
      default:
        throw UnimplementedError();
    }
  }
}
