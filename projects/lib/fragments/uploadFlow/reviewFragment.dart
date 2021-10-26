import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/style/keyValueField.dart';
import 'package:projects/style/textStyles.dart';
import '../commonsUploadFragment.dart';
import 'dart:io';

class ReviewFragment extends StatefulWidget {
  @override
  ReviewFragmentState createState() => ReviewFragmentState();
}

class ReviewFragmentState extends State<ReviewFragment> {
  InformationCollector collector = new InformationCollector();
  String infoText = "";
  Icon? fileNameIcon, titleIcon, authorIcon, licenseIcon, descriptionIcon;

  @override
  Widget build(BuildContext context) {
    setIcons();
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              // TODO Preview of infos & media
              // Here, all the info entered by the user should be previewed. When
              // the submit button is pressed and not all the fields are filled
              // out, it is also marked here. Maybe the use of collapsible menus
              // can be used to summarize sections. User should also be warned when
              // category list is empty.
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: image(),
                  ),
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                Card(
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ValueLabelField(
                              collector.fileName,
                              "file name",
                              icon: fileNameIcon,
                              replaceEmpty: true,
                          ),
                          ValueLabelField(
                            collector.title,
                            "title",
                            icon: titleIcon,
                            replaceEmpty: true,
                          ),
                          ValueLabelField(
                            collector.author,
                            "author",
                            icon: authorIcon,
                            replaceEmpty: true,
                          ),
                          ValueLabelField(
                            collector.license,
                            "license",
                            icon: licenseIcon,
                            replaceEmpty: true,
                          ),
                          ValueLabelField(
                            collector.description,
                            "image description",
                            icon: descriptionIcon,
                            replaceEmpty: true,
                          ),
                          ValueLabelField(
                              DateFormat.yMd().format(collector.date),
                              "date of creation"), // TODO local format as well
                        ],
                      ),
                    )),
                Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          "Keywords",
                          style: articleTitle,
                        ),
                        Divider(),
                        Column(
                          children: categoriesList(),
                        )
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    submit();
                  },
                  child: Text("Submit"),
                ),
                Text(infoText),
              ],
            )));
  }

  setIcons() {
    if (collector.fileName == "" || collector.fileName == null) {
      fileNameIcon = Icon(
        Icons.error_outline,
        color: Theme.of(context).errorColor,
      );
    }
    if (collector.title == "" || collector.title == null) {
      titleIcon = Icon(
        Icons.error_outline,
        color: Theme.of(context).errorColor,
      );
    }
    if (collector.author == "" || collector.author == null) {
      authorIcon = Icon(
        Icons.error_outline,
        color: Theme.of(context).errorColor,
      );
    }
    if (collector.description == "" || collector.description == null) {
      descriptionIcon = Icon(
        Icons.error_outline,
        color: Theme.of(context).errorColor,
      );
    }
    if (collector.license == "" || collector.license == null) {
      licenseIcon = Icon(
        Icons.error_outline,
        color: Theme.of(context).errorColor,
      );
    }
  }

  Widget image() {
    if (collector.image != null) {
      return Image.file(File(collector.image!.path));
    } else {
      return Container(
        alignment: Alignment.center,
        height: 170,
        color: Theme.of(context).disabledColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported),
            Padding(padding: EdgeInsets.symmetric(vertical: 2)),
            Text("No file selected"),
          ],
        ),
      );
    }
  }

  List<Widget> categoriesList() {
    List<Widget> list = new List.empty(growable: true);
    for (String category in collector.categories) {
      list.add(Text(category));
    }
    return list;
  }

  void submit() {
    if (true) {
      collector.submitData();
    } else {
      setState(() {
        infoText = "no";
      });
    }
  }

  bool checkInfo() {
    bool isOk = true;
    bool isWarning = false;
    if (collector.image == null) {
      isOk = false;
    }
    if (collector.fileName == null) {
      isOk = false;
    }
    if (collector.description == null) {
      isOk = false;
    }
    if (collector.license == null) {
      isOk = false;
    }
    if (collector.author == null) {
      isOk = false;
    }
    if (collector.title == null) {
      isOk = false;
    }
    if (collector.categories.length == 0) {
      isWarning = false;
    }
    if (collector.title == null) {
      isOk = false;
    }

    return isOk;
  }
}
