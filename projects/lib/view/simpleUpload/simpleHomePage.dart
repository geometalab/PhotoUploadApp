import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/wiki/loginHandler.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/view/simpleUpload/simpleSettingsPage.dart';
import 'package:projects/view/simpleUpload/simpleUploadPage.dart';
import 'package:projects/view/simpleUpload/simpleUserPage.dart';
import 'package:projects/view/singlePage/notLoggedIn.dart';

import '../mapViewFragment.dart';

class SimpleHomePage extends StatefulWidget {
  @override
  _SimpleHomePageState createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  InformationCollector collector = InformationCollector();
  final ImagePicker _picker = ImagePicker();
  late bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    LoginHandler().isLoggedIn().then((value) {
      isLoggedIn = value;
    });
    return Scaffold(
        appBar: _appBar(context),
        body: Center(
            child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _bigButton(Icons.folder, "Select from gallery", () async {
                if (isLoggedIn) {
                  XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    collector.images = List<XFile>.generate(1, (_) => image);
                  }
                  _openUploadPage();
                } else {
                  _openNotLoggedInPage();
                }
              }),
              _bigButton(Icons.photo_camera_outlined, "Take a picture",
                  () async {
                if (isLoggedIn) {
                  XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    collector.images = List<XFile>.generate(1, (_) => image);
                  }
                  _openUploadPage();
                } else {
                  _openNotLoggedInPage();
                }
              }),
              _bigButton(Icons.map, "Browse map", () {
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => MapFragment(),
                  ),
                );
              }),
            ],
          ),
        )));
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text("Commons Uploader"),
      actions: [
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => SimpleUsersPage(),
                ),
              );
            },
            icon: Icon(Icons.account_circle)),
        IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => SimpleSettingsPage(),
                ),
              );
            },
            icon: Icon(Icons.settings)),
      ],
    );
  }

  Widget _bigButton(IconData icon, String text, VoidCallback onPressed) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: OutlinedButton(
            onPressed: onPressed,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 50,
                  ),
                  Padding(padding: EdgeInsets.symmetric(vertical: 8)),
                  Text(
                    text,
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ),
            )),
      ),
    );
  }

  _openUploadPage() async {
    if (collector.images.isNotEmpty) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SimpleUploadPage(),
        ),
      );
    }
  }

  _openNotLoggedInPage() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Theme.of(context).colorScheme.onBackground,
          ),
          body: NotLoggedIn(),
        ),
      ),
    );
  }
}
