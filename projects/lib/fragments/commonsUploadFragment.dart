import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_tab_bar/progress_tab_bar.dart';
import 'package:projects/api/loginHandler.dart';
import 'package:projects/api/uploadService.dart';
import 'package:projects/fragments/singlePage/notLoggedIn.dart';
import 'package:projects/fragments/uploadFlow/informationFragment.dart';
import 'package:projects/fragments/uploadFlow/reviewFragment.dart';
import 'package:projects/fragments/uploadFlow/selectCategory.dart';
import 'package:projects/fragments/uploadFlow/selectImage.dart';
import 'dart:io';

class CommonsUploadFragment extends StatefulWidget {
  @override
  _CommonsUploadFragmentState createState() => _CommonsUploadFragmentState();
}

class _CommonsUploadFragmentState extends State<CommonsUploadFragment> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // TODO better colors for tab bar in dark mode
    return new Scaffold(
      backgroundColor: Theme.of(context).canvasColor,
      resizeToAvoidBottomInset: false,
      body: FutureBuilder (
        future: LoginHandler().isLoggedIn(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if(snapshot.hasData && snapshot.data == false) {
            return NotLoggedIn();
          } else {
            return _body();
          }
        },

      )
    );
  }

  Widget _body () {
    return Column(
      children: [
        Padding(padding: EdgeInsets.symmetric(vertical: 4)),
        ProgressTabBar(
          selectedTab: selectedTab,
          children: [
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 0;
                  });
                },
                label: "Select File"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 1;
                  });
                },
                label: "Add keywords"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 2;
                  });
                },
                label: "Add information"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 3;
                  });
                },
                label: "Review"),
          ],
        ),
        Divider(),
        Expanded(
          child: _content(selectedTab),
        ),
      ],
    );
  }

  Widget _content(int tab) {
    switch (tab) {
      case 0:
        return SelectImageFragment();
      case 1:
        return StatefulSelectCategoryFragment();
      case 2:
        return StatefulInformationFragment();
      case 3:
        return ReviewFragment();
      default:
        throw Exception("Invalid tab index");
    }
  }
}

class InformationCollector {
  // Singleton that saves all data from the different upload steps
  static final InformationCollector _informationCollector =
      InformationCollector._internal();

  factory InformationCollector() {
    return _informationCollector;
  }

  InformationCollector._internal();

  XFile? image;
  String? fileName;
  List<String> categories = List.empty(growable: true);
  List<IconData> categoriesThumb = List.empty(growable: true);
  String? preFillContent; // Is loaded into typeahead field
  String? title;
  String? description;
  String? author;
  String? license = 'CC0';
  DateTime date = DateTime.now();

  submitData() {
    try {
      UploadService().uploadImage(
          image!, fileName!, fileName!, description!, author!, license!, date);
    } catch (e) {
      print(e);
    }
  }

  Image getXFileImage() {
    if (image != null) {
      Image tempImage;
      tempImage = Image.file(File(image!.path));
      return tempImage;
    } else {
      throw "Tried to convert an Image which does not exist";
    }
  }
}
