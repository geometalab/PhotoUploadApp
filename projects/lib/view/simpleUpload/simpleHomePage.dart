import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/imageDataExtractor.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/view/simpleUpload/simpleUploadPage.dart';

import '../mapViewFragment.dart';

class SimpleHomePage extends StatefulWidget {
  @override
  _SimpleHomePageState createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
  InformationCollector collector = InformationCollector();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(context),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _bigButton(Icons.folder, "Select from gallery", () async {
                collector.image =
                    await _picker.pickImage(source: ImageSource.gallery);
                _openUploadPage();
              }),
              _bigButton(Icons.photo_camera_outlined, "Take a picture",
                  () async {
                collector.image =
                    await _picker.pickImage(source: ImageSource.camera);
                _openUploadPage();
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
        ));
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text("Upload to Wikimedia"),
    );
  }

  Widget _bigButton(IconData icon, String text, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: OutlinedButton(
          onPressed: onPressed,
          child: SizedBox(
            height: 200,
            width: 320,
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
    );
  }

  _openUploadPage() async {
    if (collector.image != null) {
      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => SimpleUploadPage(),
        ),
      );
    }
  }
}
