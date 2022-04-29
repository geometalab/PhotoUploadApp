import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
        title: const Text("About"),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.asset(
                    "assets/icon/icon.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Text(
                "Commons Uploader",
                style: fragmentTitle,
                textAlign: TextAlign.center,
              ),
              FutureBuilder(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    PackageInfo packageInfo = snapshot.data as PackageInfo;
                    return Text(
                        "${packageInfo.version}+${packageInfo.buildNumber}");
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
              const Padding(padding: EdgeInsets.only(bottom: 8)),
              const Text("Developed by ", style: headerText),
              const Padding(padding: EdgeInsets.only(bottom: 4)),
              const Text(
                "Fabio Zahner & Remo Steiner",
                style: headerText,
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ifsLogo,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 48),
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
                    children: const [
                      Icon(Icons.public),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text("Visit our website")
                    ],
                  )),
              TextButton(
                  onPressed: () {
                    ActionHelper().openEmail(["feedback-ifs@ost.ch"]);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
                    children: const [
                      Icon(Icons.code),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 2)),
                      Text("Code Repository")
                    ],
                  )),
              const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Text(
                    "Commons Uploader is not affiliated with the Wikimedia Foundation.",
                    style: TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
