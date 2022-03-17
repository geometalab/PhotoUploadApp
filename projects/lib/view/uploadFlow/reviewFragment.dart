import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projects/controller/wiki/filenameCheckService.dart';
import 'package:projects/model/description.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/style/heroPhotoViewRouteWrapper.dart';
import 'package:projects/view/uploadFlow/uploadProgressBar.dart';
import 'package:projects/style/keyValueField.dart';
import 'package:projects/style/textStyles.dart';
import 'package:projects/style/themes.dart';
import 'dart:io';
import 'package:projects/model/datasets.dart' as data;

class ReviewFragment extends StatefulWidget {
  @override
  _ReviewFragmentState createState() => _ReviewFragmentState();
}

class _ReviewFragmentState extends State<ReviewFragment> {
  InformationCollector collector = new InformationCollector();
  List<Widget> infoText = List.empty(growable: true);
  Icon? fileNameIcon, titleIcon, authorIcon, licenseIcon, categoryIcon;
  List<Icon?> descriptionIcon = List.empty(growable: true);
  bool fileNameAlreadyExists = false;
  int _current = 0;
  final CarouselController _controller = CarouselController();

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
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                media(),
                Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Padding(
                    padding: EdgeInsets.only(left: 8, right: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (collector.images.length == 1) // If no batch upload
                          ValueLabelField(
                            (collector.fileName ?? "") +
                                (collector.fileType ?? ""),
                            "file name",
                            icon: fileNameIcon,
                            replaceEmpty: true,
                          ),
                        if (collector.images.length > 1) // If batch upload
                          ValueLabelField(
                            (collector.fileName ?? ""),
                            "file name schema",
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
                        ValueLabelField(DateFormat.yMd().format(collector.date),
                            "date of creation"), // TODO local format instead of yMd
                      ],
                    ),
                  ),
                ),
                listWidgetBuilder(0),
                // listWidgetBuilder(1),
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
    if (collector.images.isEmpty ||
        collector.fileName == "" ||
        collector.fileName == null ||
        collector.source == "" ||
        collector.source == null ||
        collector.author == "" ||
        collector.author == null ||
        collector.license == "") {
      isError = true;
    }

    if (collector.images.isEmpty) {
      infoText.add(errorText(context, "Select the image you want to upload"));
    }
    final validFileNameChars = RegExp(r'^[a-zA-Z0-9_\- ]+$');
    if (collector.fileName == "" || collector.fileName == null) {
      infoText.add(errorText(context, "File name needs to be set"));
      fileNameIcon = errorIcon(context);
      isError = true;
    } else if (!validFileNameChars.hasMatch(collector.fileName!)) {
      infoText.add(errorText(context, "Illegal characters in file name"));
      fileNameIcon = errorIcon(context);
      isError = true;
    } else if (collector.fileName!.length < 7) {
      infoText.add(
          errorText(context, "File needs to be at least 7 characters long."));
      fileNameIcon = errorIcon(context);
      isError = true;
    } else if (collector.fileName!.length < 15) {
      infoText.add(
          warningText(context, "Make sure your file name is unique enough."));
      fileNameIcon = warningIcon(context);
    }
    if (fileNameAlreadyExists) {
      infoText.add(errorText(context, "A file with this name already exists."));
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

    // if (collector.depictions.isEmpty) {
    //   infoText.add(warningText(context, "No depictions have been added"));
    // }
    return isError;
  }

  Widget media() {
    if (collector.images.length > 1) {
      final imgList = List<Widget>.generate(collector.images.length, (index) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(4), child: image(index));
      });

      return Column(
        children: [
          CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                autoPlay: false,
                enableInfiniteScroll: false,
                viewportFraction: 0.75,
                enlargeCenterPage: true,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
              ),
              items: imgList),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key,
                      curve: Curves.ease,
                      duration: Duration(milliseconds: 500)),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)
                            .withOpacity(_current == entry.key ? 0.8 : 0.3)),
                  ),
                );
              }).toList())
        ],
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        width: double.infinity,
        alignment: Alignment.center,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: image(0),
        ),
      );
    }
  }

  // Supplies the image or a placeholder if no image is in the collector
  Widget image(int image) {
    if (collector.images.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HeroPhotoViewRouteWrapper(
                  imageProvider: FileImage(File(collector.images[image].path)),
                ),
              ));
        },
        child: Container(
          child: Hero(
            tag: "image" + image.toString(),
            child: Image.file(
              File(collector.images[image].path),
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
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
            height: 48,
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
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: thumbnail,
            ),
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
      if (await FilenameCheckService()
          .fileExists(collector.fileName!, collector.fileType!)) {
        fileNameAlreadyExists = true;
        hideSendingProgressBar();
        setState(() {});
        return;
      }
      await collector.submitData();
      setState(() {
        collector.clear();
      });
    }
  }

  UploadProgressBar? _sendingMsgProgressBar;
  void showSendingProgressBar() {
    _sendingMsgProgressBar = UploadProgressBar();
    _sendingMsgProgressBar!.show(context);
  }

  void hideSendingProgressBar() {
    if (_sendingMsgProgressBar != null) {
      _sendingMsgProgressBar!.hide();
    }
  }
}
