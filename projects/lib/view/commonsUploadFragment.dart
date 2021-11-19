import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_tab_bar/progress_tab_bar.dart';
import 'package:projects/controller/loginHandler.dart';
import 'package:projects/controller/uploadService.dart';
import 'package:projects/view/singlePage/notLoggedIn.dart';
import 'package:projects/view/uploadFlow/descriptionFragment.dart';
import 'package:projects/view/uploadFlow/informationFragment.dart';
import 'package:projects/view/uploadFlow/reviewFragment.dart';
import 'package:projects/view/uploadFlow/selecItems.dart';
import 'package:projects/view/uploadFlow/selectImage.dart';
import 'dart:io';

class CommonsUploadFragment extends StatefulWidget {
  @override
  _CommonsUploadFragmentState createState() => _CommonsUploadFragmentState();
}

class _CommonsUploadFragmentState extends State<CommonsUploadFragment> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    // TODO noticeable frame drop when switching tabs
    return new Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        resizeToAvoidBottomInset: false,
        body: FutureBuilder(
          future: LoginHandler().isLoggedIn(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData && snapshot.data == false) {
              return NotLoggedIn();
            } else {
              return _body();
            }
          },
        ));
  }

  Widget _body() {
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
                label: "Depicts"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 2;
                  });
                },
                label: "Categories"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 3;
                  });
                },
                label: "Describe"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 4;
                  });
                },
                label: "Add information"),
            ProgressTab(
                onPressed: () {
                  setState(() {
                    selectedTab = 5;
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
        return StatefulSelectItemFragment(1);
      case 2:
        return StatefulSelectItemFragment(0);
      case 3:
        return DescriptionFragment();
      case 4:
        return StatefulInformationFragment();
      case 5:
        return ReviewFragment();
      default:
        throw Exception("Invalid tab index");
    }
  }
}

// Singleton that saves all data from the different upload steps
class InformationCollector {
  static final InformationCollector _informationCollector =
      InformationCollector._internal();

  factory InformationCollector() {
    return _informationCollector;
  }
  InformationCollector._internal();

  XFile? image;
  String? fileName;
  String? fileType;
  List<String> categories = List.empty(growable: true);
  List<Map<String, dynamic>?> categoriesThumb = List.empty(growable: true);
  List<String> depictions = List.empty(growable: true);
  List<Map<String, dynamic>?> depictionsThumb = List.empty(growable: true);
  String? preFillContent; // Is loaded into typeahead categories field
  List<Description> description = List.empty(growable: true);
  bool ownWork = false;
  String? source;
  String? author;
  String? license = 'CC0';
  DateTime date = DateTime.now();

  // Should only be called when all fields are filled correctly
  submitData() async {
    String _author = author!;
    String _source = source!;
    if (ownWork) {
      Userdata? userdata = await LoginHandler().getUserInformationFromFile();
      if (userdata == null) {
        throw ("Userdata is null.");
      }
      _author = '[[User:${userdata.username}|${userdata.username}]]';
      _source = "Own Work";
    }
    try {
      await UploadService().uploadImage(image!, fileName! + fileType!, _source,
         description, _author, license!, date, categories, depictions);
    } catch (e) {
      throw (e);
    }
  }

  clear() {
    image = null;
    fileName = null;
    fileType = null;
    description.clear();
    categories.clear();
    categoriesThumb.clear();
    depictions.clear();
    depictionsThumb.clear();
    preFillContent = null;
    ownWork = false;
    source = null;
    author = null;
    license = 'CC0';
    date = DateTime.now();
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
