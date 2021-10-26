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

  Icon errorIcon(BuildContext context) {
    return Icon(
      Icons.error_outline,
      color: Theme.of(context).errorColor,
    );
  }

  Icon warningIcon(BuildContext context) {
    return Icon(
      Icons.warning_amber_rounded,
      color: Colors.orangeAccent,
    );
  }

  @override
  Widget build(BuildContext context) {
    setIcons();
    return Container(
        child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child:
                        image(), // TODO Implement fullscreen view of image on click
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
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          "Keywords",
                          style: articleTitle,
                        ),
                        Column(
                          children: categoriesList(),
                        )
                      ],
                    ),
                  ),
                ),
                Text(infoText),
                ElevatedButton(
                  onPressed: () {
                    submit();
                  },
                  child: Text("Submit"),
                ),
              ],
            )));
  }

  setIcons() {
    if (collector.fileName == "" || collector.fileName == null) {
      fileNameIcon = errorIcon(context);
    }
    if (collector.title == "" || collector.title == null) {
      titleIcon = errorIcon(context);
    }
    if (collector.author == "" || collector.author == null) {
      authorIcon = errorIcon(context);
    }
    if (collector.description == "" || collector.description == null) {
      descriptionIcon = errorIcon(context);
    }
    if (collector.license == "" || collector.license == null) {
      licenseIcon = errorIcon(context);
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

    // If no keywords in list, display warning message
    if (collector.categories.isEmpty) {
      list.add(Divider());
      list.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "No categories added",
              style: objectDescription,
            ),
            warningIcon(context),
          ],
        ),
      ));
      return list;
    }

    // Add all categories to the list
    for (int i = 0; i < collector.categories.length; i++) {
      Widget thumbnail;
      Map<String, dynamic>? thumbnailJson = collector.categoriesThumb[i];
      // If no thumbnail available for category
      if (thumbnailJson == null) {
        thumbnail = Container(
            height: 64,
            color: Theme.of(context).disabledColor,
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Icon(Icons.image_not_supported),
            ));
      } else {
        thumbnail = Image.network(thumbnailJson['url'], height: 64);
      }

      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              collector.categories[i],
              overflow: TextOverflow.fade,
              style: objectDescription,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: thumbnail,
          ),
        ],
      ));
    }

    // Insert divider between list elements
    for (int i = list.length - 1; i >= 0; i--) {
      list.insert(i, Divider());
    }
    return list;
  }

  void submit() {
    if (checkInfo()) {
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
