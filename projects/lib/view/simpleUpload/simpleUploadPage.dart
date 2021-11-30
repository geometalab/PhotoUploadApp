import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        children: [
          _previewImage(),
          MediaTitleWidget(),
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

  List<Widget> descriptionWidgets() {
    List<Widget> list = new List.empty(growable: true);
    list.add(MediaTitleWidget());
    list.add(Divider(indent: 10, endIndent: 10));
    list.add(Padding(
      padding: EdgeInsets.only(top: 16, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.text_fields_outlined,
            color: CustomColors().getDefaultIconColor(Theme.of(context)),
          ),
          Padding(padding: EdgeInsets.only(left: 18)),
          Text(
            "Descriptions: ",
            textScaleFactor: 1.2,
            style: TextStyle(
                color: CustomColors().getDefaultIconColor(Theme.of(context))),
          ),
        ],
      ),
    ));
    if (collector.description.isEmpty) {
      collector.description.add(Description(
          language:
              "en")); // TODO localize language with preferences, phone language
    }
    String? descriptionLabel;
    for (int i = 0; i < collector.description.length; i++) {
      descriptionLabel = data.languages['${collector.description[i].language}'];
      if (descriptionLabel == null) {
        throw ("Description language could not be resolved");
      }
      descriptionLabel += " description";

      list.add(Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(bottom: 1),
                    child: TextFormField(
                        // TODO flexible height fields
                        initialValue: collector.description[i].content,
                        onChanged: (value) {
                          collector.description[i].content = value;
                        },
                        maxLines: 7,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: descriptionLabel,
                          hintText: 'Write a meaningful description',
                        )),
                  )),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (i != 0)
                        IconButton(
                          // TODO if text is entered, "are you sure" prompt before deleting
                          onPressed: () {
                            setState(() {
                              collector.description.removeAt(i);
                            });
                          },
                          icon: Icon(Icons.close),
                          color: CustomColors()
                              .getDefaultIconColor(Theme.of(context)),
                        ),
                      if (i == 0)
                        // This widget ensures the dropdown remains aligned with text input
                        Container(),
                      DropdownButton<String>(
                        value: collector.description[i].language,
                        onChanged: (String? newValue) {
                          setState(() {
                            collector.description[i].language = newValue!;
                          });
                        },
                        icon: const Icon(Icons.arrow_downward),
                        iconSize: 24,
                        elevation: 16,
                        isDense:
                            true, // TODO when i remove dropdown isnt aligned with textfield, but better looking
                        underline: Container(
                          height: 2,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        items: data.languages.keys
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ))));
    }
    list.add(TextButton(
      onPressed: () {
        setState(() {
          collector.description.add(Description());
        });
      },
      child: Row(
        children: [
          Icon(Icons.add),
          Text("Add another language"),
        ],
      ),
    ));

    return list;
  }
}
