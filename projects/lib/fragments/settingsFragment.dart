import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsFragment extends StatelessWidget {

  static SharedPreferences? prefs;

  @override
  Widget build(BuildContext context) {
    // TODO: implement settings
    // TODO maybe multi language support
    return new Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(padding: EdgeInsets.all(10),
                child: Text("App Theme"),
              ),
              Padding(padding: EdgeInsets.all(10),
                child: FutureBuilder(
                  future: getSharedPreferences('theme'),
                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if(snapshot.hasData){
                      String snapshotValue = snapshot.data;
                      if(snapshotValue == "no value") {
                        snapshotValue = 'Light';
                        setSharedPreferences('theme', 'Light');
                      }
                      return DropdownButton<String>( // TODO 3rd option: Use system theme
                        value: snapshotValue,
                        onChanged: (String? newValue) {
                          if(newValue == "Light") {
                            EasyDynamicTheme.of(context).changeTheme(dark: false);
                          } else if (newValue == "Dark") {
                            EasyDynamicTheme.of(context).changeTheme(dark: true);
                          } else if (newValue == 'Use System Theme'){
                            EasyDynamicTheme.of(context).changeTheme(dynamic: true);
                          } else {
                            throw("Theme string could not be read");
                          }
                          snapshotValue = newValue!;
                          setSharedPreferences('theme', newValue);
                        },
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).accentColor,
                        ),
                        items: <String>['Light', 'Dark', 'Use System Theme']
                          .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                      );
                    } else {
                      return DropdownButton(
                        items: null,
                        onChanged: null,
                        disabledHint: Text("Loading preferences"),
                      );
                    }
                  },
                )

              ),
            ],
          )
        ],
      ),
    );
  }

  setSharedPreferences(String key, String value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString(key, value);
    });
  }

  Future<String> getSharedPreferences(String key) async {
    prefs = await SharedPreferences.getInstance();
    String? key = prefs!.getString('stringValue');
    if(key != null){
      return key;
    }else {
     return "no value";
    }
  }

}