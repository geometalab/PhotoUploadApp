import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import 'package:projects/controller/wiki/login_handler.dart';
import 'package:projects/model/datasets.dart';
import 'package:projects/model/information_collector.dart';
import 'package:projects/page_container.dart';
import 'package:projects/style/info_popup.dart';
import 'package:projects/view/about_fragment.dart';
import 'package:projects/model/texts.dart' as texts;
import 'package:projects/view/simpleUpload/simple_settings_page.dart';
import 'package:projects/view/singlePage/image_selector.dart';
import 'package:projects/view/singlePage/introduction_view.dart';
import 'package:provider/provider.dart';

// TODO a "author name" text field, which gets filled into "author" field when "This is my own work" checkbox is tapped.

class SettingsFragment extends StatefulWidget {
  const SettingsFragment({Key? key}) : super(key: key);

  @override
  _SettingsFragmentState createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  static const dividerHeight = 0.0;

  late final SettingsManager manager = SettingsManager();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _appThemeSwitch(context),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            const Divider(
              height: dividerHeight,
            ),
            _simpleModeSwitch(context),
            const Divider(
              height: dividerHeight,
            ),
            _backgroundImageSelector(context),
            const Divider(
              height: dividerHeight,
            ),
            _rewatchIntroButton(context),
            const Divider(
              height: dividerHeight,
            ),
            _clearPrefsButton(context),
            const Divider(
              height: dividerHeight,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
            // About button
            _aboutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _appThemeSwitch(BuildContext context) {
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("App Theme"),
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
              throw ("Theme string could not be read. NewValue: $newValue");
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
    );
  }

  Widget _simpleModeSwitch(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text("Simple Mode"),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 4)),
                  InfoPopUp(texts.simpleModeInfo),
                ],
              ),
              Switch.adaptive(
                  value: manager.isSimpleMode(),
                  onChanged: (bool value) {
                    switchEasyMode(value, context);
                  })
            ]));
  }

  Widget _backgroundImageSelector(BuildContext context) {
    callBack(int newIndex) {
      String path = assetImages()[newIndex];
      manager.setBackgroundImage(path);
    }

    return RawMaterialButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageSelectorFragment(
                    assetImages(),
                    callBack,
                    assetImages().indexWhere((element) {
                      return element == SettingsManager().getBackgroundImage();
                    })),
              ));
        },
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Select background image"),
              Icon(Icons.chevron_right)
            ],
          ),
        ));
  }

  _rewatchIntroButton(BuildContext context) {
    return RawMaterialButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const IntroductionView()));
        },
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Show first-time Introduction"),
            ],
          ),
        ));
  }

  _clearPrefsButton(BuildContext context) {
    return RawMaterialButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Delete local storage"),
              content: const Text(
                  "This will delete login data and local cache and close the app. The introductory slides will be shown again on the next start."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    manager.clearPrefs();
                    LoginHandler().logOut();
                    Navigator.of(ctx).pop();
                    setState(() {
                      switchEasyMode(true, context);
                    });
                    setState(() {});
                  },
                  child: const Text("Delete"),
                ),
              ],
            ),
          );
        },
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Delete local storage"),
            ],
          ),
        ));
  }

  _aboutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutFragment()),
        );
      },
      label: const Text("About"),
      icon: const Icon(Icons.info_outline),
    );
  }

  switchEasyMode(bool value, BuildContext context) {
    InformationCollector().clear();
    // TODO remove flickers and ugly transitions
    manager.setSimpleMode(value);
    if (manager.isSimpleMode()) {
      Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 0;
      Navigator.push(
        context,
        PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                const SimpleSettingsPage()), // No transition animation
      );
    } else {
      setState(() {
        Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 7;
        Navigator.pop(context);
      });
      Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 7;
    }
  }
}
