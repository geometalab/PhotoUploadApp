import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';
import 'package:projects/style/unorderedListWidget.dart';

class AboutFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeMode? themeMode = EasyDynamicTheme.of(context).themeMode;
    if (themeMode == ThemeMode.light) {
      return Scaffold(
        appBar: AppBar(
          title: Text("About"),
        ),
        body: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Wikimedia Commons Uploader App", style: fragmentTitle),
                  Padding(padding: EdgeInsets.only(bottom: 8)),
                  Text("Developed by:", style: articleDescription),
                  Padding(padding: EdgeInsets.only(bottom: 4)),
                  Text("• Fabio Zahner"),
                  Text("• Remo Steiner"),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 300,
                      child: Image.asset(
                          "assets/media/logos/IFS.png"),


                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: SizedBox(
                      width: 220,
                      child: Image.asset("assets/media/logos/OST.png"),
                    ),
                  )
                ],

              ),
            )
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("About"),
        ),
        body: Center(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Wikimedia Commons Uploader App", style: fragmentTitle),
                  Padding(padding: EdgeInsets.only(bottom: 8)),
                  Text("Developed by:", style: articleDescription),
                  Padding(padding: EdgeInsets.only(bottom: 4)),
                  Text("• Fabio Zahner"),
                  Text("• Remo Steiner"),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                      width: 380,
                      child: Image.asset(
                          "assets/media/logos/IFS_fordarkmode.png"),

                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                    child: SizedBox(
                      width: 300,
                      child: Image.asset("assets/media/logos/OST_fordarkmode.png"),
                    ),
                  )
                ],

              ),
            )
        ),
      );
    }
  }
}