import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';

class AboutFragment extends StatelessWidget {
  // TODO what even goes in the about page??
  @override
  Widget build(BuildContext context) {
    late Image ifsLogo;
    late Image ostLogo;

    Brightness? brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      // TODO Recognize "system default" color
      ifsLogo = Image.asset("assets/media/logos/IFS_dark.png");
      ostLogo = Image.asset("assets/media/logos/OST_dark.png");
    } else {
      ifsLogo = Image.asset("assets/media/logos/IFS.png");
      ostLogo = Image.asset("assets/media/logos/OST.png");
    }
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
            Text("Developed by:", style: objectDescription),
            Padding(padding: EdgeInsets.only(bottom: 4)),
            Text("• Fabio Zahner"),
            Text("• Remo Steiner"),
            Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 300,
                child: ifsLogo,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: SizedBox(
                width: 220,
                child: ostLogo,
              ),
            )
          ],
        ),
      )),
    );
  }
}
