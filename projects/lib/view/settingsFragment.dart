import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/settingsManager.dart';
import 'package:projects/view/aboutFragment.dart';
import 'package:projects/view/singlePage/imageSelector.dart';

// TODO a "author name" text field, which gets filled into "author" field when "This is my own work" checkbox is tapped.

class SettingsFragment extends StatelessWidget {
  late final SettingsManager manager = SettingsManager();
  @override
  Widget build(BuildContext context) {
    ThemeMode? themeMode = EasyDynamicTheme.of(context).themeMode;
    String dropdownValue;
    if (themeMode == ThemeMode.light) {
      dropdownValue = "Light";
    } else if (themeMode == ThemeMode.dark) {
      dropdownValue = "Dark";
    } else if (themeMode == ThemeMode.system) {
      dropdownValue = "Use System Theme";
    } else {
      throw ("App theme could not be determined");
    }

    callBack(int newIndex) {
      String path = assetImages()[newIndex];
      manager.setBackgroundImage(path);
    }

    return new Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App Theme Selector
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("App Theme"),
                DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    if (newValue == "Light") {
                      EasyDynamicTheme.of(context).changeTheme(dark: false);
                    } else if (newValue == "Dark") {
                      EasyDynamicTheme.of(context).changeTheme(dark: true);
                    } else if (newValue == 'Use System Theme') {
                      EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                    } else {
                      throw ("Theme string could not be read");
                    }
                    dropdownValue = newValue!;
                  },
                  icon: const Icon(Icons.arrow_downward),
                  iconSize: 24,
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  items: <String>['Light', 'Dark', 'Use System Theme']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                )
              ],
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            Divider(
              height: 0,
            ),
            // Background image selector
            RawMaterialButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageSelectorFragment(
                            assetImages(),
                            callBack,
                            assetImages().indexWhere((element) {
                              return element ==
                                  SettingsManager().getBackgroundImage();
                            })),
                      ));
                },
                child: SizedBox(
                  height: 64,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Select background image"),
                      Icon(Icons.chevron_right)
                    ],
                  ),
                )),
            Divider(
              height: 0,
            ),
            Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            // About button
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutFragment()),
                );
              },
              label: Text("About"),
              icon: Icon(Icons.info_outline),
            )
          ],
        ),
      ),
    );
  }

  List<String> assetImages() {
    String path = "assets/media/backgrounds/";
    return [
      path + "aurora.jpg",
      path + "frogs.jpg",
      path + "national_park.jpg",
      path + "old_town.jpg",
      path + "roundhouse.jpg",
      path + "train.jpg",
      path + "waterfalls.jpg",
      ""
    ];
  }
}
