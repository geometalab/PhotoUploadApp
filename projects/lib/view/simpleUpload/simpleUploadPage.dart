import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/filenameCheckService.dart';
import 'package:projects/controller/internal/imageDataExtractor.dart';
import 'package:projects/controller/wiki/loginHandler.dart';
import 'package:projects/model/description.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/style/HeroPhotoViewRouteWrapper.dart';
import 'package:projects/style/themes.dart';
import 'package:projects/view/simpleUpload/simpleCategoriesPage.dart';
import 'package:projects/view/singlePage/notLoggedIn.dart';
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
    return FutureBuilder(
      future: LoginHandler().isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData && snapshot.data == false) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
            ),
            body: NotLoggedIn(),
          );
        } else {
          return Scaffold(
            appBar: _appBar(context),
            body: FutureBuilder(
              future: ImageDataExtractor().futureCollector(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      _previewImage(),
                      DescriptionFragment(),
                    ],
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
              },
            ),
          );
        }
      },
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text("Upload to Wikimedia"),
      actions: [
        IconButton(
            onPressed: () {
              _nextPage(context);
            },
            icon: Icon(Icons.arrow_forward))
      ],
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

  _nextPage(BuildContext context) async {
    if (await _dataIsValid(context)) {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SimpleCategoriesPage(),
          ));
    }
  }

  Future<bool> _dataIsValid(BuildContext context) async {
    String? message = await _errorChecker();
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
      return false;
    } else {
      return true;
    }
  }

  Future<String?> _errorChecker() async {
    if (collector.image == null) {
      return "Please go back and select an image.";
    } else if (collector.fileName == null || collector.fileName!.isEmpty) {
      return "Enter a file name";
    } else if (collector.fileName!.length < 7) {
      return "File name is too short";
    } else if (collector.description.isEmpty) {
      collector.description.add(Description(language: "en"));
    }

    if (collector.description.length == 1 &&
        collector.description[0].content == "") {
      return "Add at least one description";
    } else {
      bool alreadyWarned = false;
      for (Description description in collector.description) {
        if (description.content.length < 10) {
          // Add info text only if not already in place
          if (!alreadyWarned) {
            return "A description is very short";
            alreadyWarned = true;
          }
        }
        if (description.content.isEmpty) {
          return "A description is empty";
        }
      }
      // If a language appears in more then one desc
      if (collector.description.any((element) {
        int numberOfAppearances = 0;
        for (Description description in collector.description) {
          if (description.language == element.language) {
            numberOfAppearances++;
          }
        }
        return numberOfAppearances > 1;
      })) {
        return "Multiple descriptions are in the same language";
      }
    }
    if (collector.fileType == null) {
      throw "Filetype is null.";
    }
    if (await FilenameCheckService()
        .fileExists(collector.fileName!, collector.fileType!)) {
      return "A file with this name already exists.";
    }
  }
}
