import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/view/uploadFlow/descriptionFragment.dart';
import 'package:projects/view/uploadFlow/uploadProgressBar.dart';
import 'package:projects/style/keyValueField.dart';
import 'package:projects/style/textStyles.dart';
import 'package:projects/style/themes.dart';
import '../commonsUploadFragment.dart';
import 'dart:io';
import 'package:projects/model/datasets.dart' as data;

class ReviewFragment extends StatefulWidget {
  @override
  ReviewFragmentState createState() => ReviewFragmentState();
}

class ReviewFragmentState extends State<ReviewFragment> {
  InformationCollector collector = new InformationCollector();
  List<Widget> infoText = List.empty(growable: true);
  Icon? fileNameIcon, titleIcon, authorIcon, licenseIcon, categoryIcon;
  List<Icon?> descriptionIcon = List.empty(growable: true);

  Icon errorIcon(BuildContext context) {
    return Icon(
      Icons.error_outline,
      color: Theme.of(context).errorColor,
    );
  }

  Icon warningIcon(BuildContext context) {
    return Icon(
      Icons.warning_amber_rounded,
      color: CustomColors.WARNING_COLOR,
    );
  }

  Text errorText(BuildContext context, String text) {
    return Text(text, style: TextStyle(color: Theme.of(context).errorColor));
  }

  Text warningText(BuildContext context, String text) {
    return Text(text, style: TextStyle(color: CustomColors.WARNING_COLOR));
  }

  Text statusText(BuildContext context, String text) {
    return Text(text, style: TextStyle(color: Colors.green));
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
                            (collector.fileName ?? "") +
                                (collector.fileType ?? ""),
                            "file name",
                            icon: fileNameIcon,
                            replaceEmpty: true,
                          ),
                          ValueLabelField(
                            collector.source,
                            "source",
                            icon: titleIcon,
                            replaceEmpty: true,
                          ),
                          Column(
                            children: descriptionsBuilder(),
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
                listWidgetBuilder(0),
                Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                listWidgetBuilder(1),
                Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                Column(
                  children: infoText,
                ),
                Padding(padding: EdgeInsets.symmetric(vertical: 6)),
                SizedBox(
                  width: 180,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: infoCheckError()
                        ? null // Button only enables if infoCheckError returns false
                        : () async => submit(),
                    child: Text("Submit"),
                  ),
                ),
              ],
            )));
  }

  // Checks all fields and properties and returns false when possible to submit.
  // Also sets warning and error icons, and sets the info texts.
  bool infoCheckError() {
    bool isError = false;

    infoText.clear(); // Clear all warnings and errors
    descriptionIcon.clear();

    // The fields which need to be filled out
    if (collector.image == null ||
        collector.fileName == "" ||
        collector.fileName == null ||
        collector.source == "" ||
        collector.source == null ||
        collector.author == "" ||
        collector.author == null ||
        collector.license == "") {
      isError = true;
    }

    if (collector.image == null) {
      infoText.add(errorText(context, "Select the image you want to upload"));
    }

    if (collector.fileName == "" || collector.fileName == null) {
      infoText.add(errorText(context, "File name needs to be set"));
      fileNameIcon = errorIcon(context);
      isError = true;
    } else if (collector.fileName!.length < 7) {
      infoText.add(errorText(context, "File name is too short"));
      fileNameIcon = errorIcon(context);
      isError = true;
    } else if (collector.fileName!.length < 15) {
      // TODO find other cases of unspecific file names
      infoText.add(
          warningText(context, "Make sure you file name is unique enough"));
      fileNameIcon = warningIcon(context);
    }

    if (collector.source == "" || collector.source == null) {
      infoText.add(errorText(context, "Source needs to be set"));
      titleIcon = errorIcon(context);
    }

    if (collector.description.isEmpty) {
      collector.description.add(Description(language: "en"));
    }

    if (collector.description.length == 1 &&
        collector.description[0].content == "") {
      infoText.add(errorText(context, "Add at least one description"));
      descriptionIcon.insert(0, errorIcon(context));
      isError = true;
    } else {
      bool alreadyWarned = false;
      for (Description description in collector.description) {
        descriptionIcon.add(null);
        if (description.content.length < 10) {
          // Add info text only if not already in place
          if (!alreadyWarned) {
            infoText.add(warningText(context, "A description is very short"));
            alreadyWarned = true;
          }
          descriptionIcon.insert(
              collector.description.indexOf(description), warningIcon(context));
        }
        if (description.content.isEmpty) {
          infoText.add(errorText(context, "A description is empty"));
          descriptionIcon.insert(
              collector.description.indexOf(description), errorIcon(context));
          isError = true;
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
        infoText.add(errorText(
            context, "Multiple descriptions are in the same language"));
        isError = true;
      }
    }

    if (collector.author == "" || collector.author == null) {
      infoText.add(errorText(context, "Author needs to be set"));
      authorIcon = errorIcon(context);
    }

    if (collector.categories.isEmpty) {
      infoText.add(warningText(context, "No categories have been added"));
    }

    if (collector.depictions.isEmpty) {
      infoText.add(warningText(context, "No depictions have been added"));
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

  List<Widget> descriptionsBuilder() {
    List<Widget> list = List.empty(growable: true);
    for (Description description in collector.description) {
      String descriptionLabel = data.languages['${description.language}']!;
      descriptionLabel += " description";
      list.add(ValueLabelField(
        description.content,
        descriptionLabel,
        icon: descriptionIcon
            .elementAt(collector.description.indexOf(description)),
        replaceEmpty: true,
      ));
    }
    return list;
  }

  // The widget for the Categories and Depicts summaries
  Widget listWidgetBuilder(int useCase) {
    String title;
    if (useCase == 0) {
      title = "Categories";
    } else {
      title = "Depicts";
    }
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Column(
          children: [
            Text(
              title,
              style: articleTitle,
            ),
            Column(
              children: listContentBuilder(useCase),
            )
          ],
        ),
      ),
    );
  }

  // Returns a list with all entered categories/depicts items
  List<Widget> listContentBuilder(int useCase) {
    List<String> titles;
    List<Map<String, dynamic>?> thumbs;
    if (useCase == 0) {
      titles = collector.categories;
      thumbs = collector.categoriesThumb;
    } else if (useCase == 1) {
      titles = collector.depictions;
      thumbs = collector.depictionsThumb;
    } else
      throw ("Incorrect useCase param for categoriesList");

    List<Widget> list = new List.empty(growable: true);
    // If no keywords in list, display warning message
    if (titles.isEmpty) {
      list.add(Divider());
      list.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "No items added",
              style: objectDescription,
            ),
            warningIcon(context),
          ],
        ),
      ));
      return list;
    }

    // Add all categories to the list
    for (int i = 0; i < titles.length; i++) {
      Widget thumbnail;
      Map<String, dynamic>? thumbnailJson = thumbs[i];
      // If no thumbnail available for category
      if (thumbnailJson == null) {
        thumbnail = Container(
            height: 64,
            color: CustomColors.NO_IMAGE_COLOR,
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Icon(Icons.image_not_supported,
                  color: CustomColors.NO_IMAGE_CONTENTS_COLOR),
            ));
      } else {
        thumbnail = Image.network(thumbnailJson['url'], height: 64);
      }

      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              titles[i],
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

  submit() async {
    if (!infoCheckError()) {
      showSendingProgressBar();
      await collector.submitData();
      setState(() {
        collector.clear();
      });
    }
  }

  void showSendingProgressBar() {
    UploadProgressBar _sendingMsgProgressBar = UploadProgressBar();
    _sendingMsgProgressBar.show(context);
  }
}
