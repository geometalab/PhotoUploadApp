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
  List<Widget> infoText = List.empty(growable: true);
  Icon? fileNameIcon,
      titleIcon,
      authorIcon,
      licenseIcon,
      descriptionIcon,
      categoryIcon;

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

  Text errorText(BuildContext context, String text) {
    return Text(text, style: TextStyle(color: Theme.of(context).errorColor));
  }

  Text warningText(BuildContext context, String text) {
    return Text(text, style: TextStyle(color: Colors.orangeAccent));
  }

  @override
  Widget build(BuildContext context) {
    infoCheckError();
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
                            "file name", // TODO does the filename need file name extension? if yes, where should it be added?
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
                            collector.description,
                            "image description",
                            icon: descriptionIcon,
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
                              DateFormat.yMd().format(collector.date),
                              "date of creation"), // TODO local format as well
                        ],
                      ),
                    )),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                ),
                Card(
                  margin: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                Padding(padding: EdgeInsets.only(bottom: 8)),
                Column(
                  children: infoText,
                ),
                Padding(padding: EdgeInsets.only(bottom: 8)),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: infoCheckError()
                        ? null
                        : () =>
                            submit(), // Button only enables if infoCheckError returns false
                    child: Text("Submit"),
                  ),
                )
              ],
            )));
  }

  // Checks all fields and properties and returns false when possible to submit.
  // Also sets warning and error icons, and sets the info texts.
  bool infoCheckError() {
    bool isError = false;

    infoText.clear(); // Clear all warnings and errors

    // The fields which need to be filled out
    if (collector.image == null ||
            collector.fileName == "" ||
            collector.fileName == null ||
            collector.title == "" ||
            collector.title == null ||
            collector.author == "" ||
            collector.author == null ||
            collector.license == "" ||
            collector.license == null // Should not be possible
        ) {
      isError = true;
    }

    if (collector.image == null) {
      infoText.add(errorText(context, "Select the image you want to upload"));
    }
    if (collector.fileName == "" || collector.fileName == null) {
      infoText.add(errorText(context, "File name needs to be set"));
      fileNameIcon = errorIcon(context);
    } else if (collector.fileName!.length < 5) {
      infoText.add(warningText(context, "File name is very short"));
    }
    if (collector.title == "" || collector.title == null) {
      infoText.add(errorText(context, "Title needs to be set"));
      titleIcon = errorIcon(context);
    }
    if (collector.description == "" || collector.description == null) {
      infoText.add(warningText(context, "No description has been added"));
      descriptionIcon = warningIcon(context);
    }
    if (collector.author == "" || collector.author == null) {
      infoText.add(errorText(context, "Author needs to be set"));
      authorIcon = errorIcon(context);
    }
    if (collector.categories.isEmpty) {
      infoText.add(warningText(context, "No categories have been added"));
    }
    return isError;
  }

  // Supplies the image or a placeholder if no image is in the collector
  Widget image() {
    if (collector.image != null) {
      return Image.file(File(collector.image!.path));
    } else {
      return Container(
        alignment: Alignment.center,
        height: 170,
        color: Theme.of(context).disabledColor.withAlpha(50),
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

  // A list with all entered categories
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

  submit() {
    if (!infoCheckError()) {
      collector.submitData();
    }
  }
}
