import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/internal/actionHelper.dart';
import 'package:projects/style/textStyles.dart';

class AboutFragment extends StatelessWidget {
  // TODO what even goes in the about page??
  @override
  Widget build(BuildContext context) {
    late Image ifsLogo;
    late Image ostLogo;

    Brightness? brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
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
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 120),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    "assets/icon/icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                "Commons Uploader",
                style: fragmentTitle,
                textAlign: TextAlign.center,
              ),
              Padding(padding: EdgeInsets.only(bottom: 8)),
              Text("Developed by ", style: headerText),
              Padding(padding: EdgeInsets.only(bottom: 4)),
              Text(
                "Fabio Zahner & Remo Steiner",
                style: headerText,
              ),
              Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ifsLogo,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 48),
                child: SizedBox(
                  width: double.infinity,
                  child: ostLogo,
                ),
              ),
              TextButton(
                  onPressed: () {
                    ActionHelper().launchUrl("https://www.ifs.hsr.ch/");
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.public),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text("Visit our website")
                    ],
                  )),
              TextButton(
                  onPressed: () {
                    ActionHelper().openEmail(["rj-geometalab@ost.ch"]);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text("Contact us")
                    ],
                  )),
              TextButton(
                  onPressed: () {
                    ActionHelper().launchUrl(
                        "https://github.com/geometalab/PhotoUploadApp");
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.code),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text("Code Repository")
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
