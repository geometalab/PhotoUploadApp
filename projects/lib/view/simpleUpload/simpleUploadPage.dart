import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/model/description.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/style/HeroPhotoViewRouteWrapper.dart';
import 'package:projects/style/themes.dart';
import 'package:projects/view/uploadFlow/descriptionFragment.dart';
import 'package:projects/model/datasets.dart' as data;

class SimpleUploadPage extends StatefulWidget {
  @override
  _SimpleUploadPageState createState() => _SimpleUploadPageState();
}

class _SimpleUploadPageState extends State<SimpleUploadPage> {
  InformationCollector collector = InformationCollector();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _previewImage(),
          DescriptionFragment(),
        ],
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text("Upload to Wikimedia"),
    );
  }

  Widget _previewImage() {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _previewImageProvider(),
      ),
    );
  }

  Widget _previewImageProvider() {
    if (collector.image != null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeroPhotoViewRouteWrapper(
                  imageProvider: FileImage(File(collector.image!.path)),
                ),
              ));
        },
        child: Container(
          child: Hero(
            tag: "someTag",
            child: Image.file(
              File(collector.image!.path),
            ),
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        height: 170,
        color: CustomColors.NO_IMAGE_COLOR,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported,
                color: CustomColors.NO_IMAGE_CONTENTS_COLOR, size: 40),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Text(
              "No file selected",
              style: TextStyle(color: CustomColors.NO_IMAGE_CONTENTS_COLOR),
            ),
          ],
        ),
      );
    }
  }
}
