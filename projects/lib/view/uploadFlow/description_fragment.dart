import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/file_name_check_service.dart';
import 'package:projects/model/datasets.dart' as data;
import 'package:projects/model/description.dart';
import 'package:projects/model/information_collector.dart';
import 'package:projects/style/info_popup.dart';
import 'package:projects/style/themes.dart';
import 'package:projects/style/text_styles.dart' as text_styles;

class DescriptionFragment extends StatefulWidget {
  const DescriptionFragment({Key? key}) : super(key: key);

  @override
  _DescriptionFragment createState() => _DescriptionFragment();
}

class _DescriptionFragment extends State<DescriptionFragment> {
  InformationCollector collector = InformationCollector();
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        controller: scrollController,
        child: Column(children: descriptionWidgets()));
  }

  List<Widget> descriptionWidgets() {
    List<Widget> list = List.empty(growable: true);
    list.add(const MediaTitleWidget());
    list.add(const Divider(indent: 10, endIndent: 10));
    list.add(Padding(
      padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(
            Icons.text_fields_outlined,
            color: CustomColors().getDefaultIconColor(Theme.of(context)),
          ),
          const Padding(padding: EdgeInsets.only(left: 18)),
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
      descriptionLabel = data.languages[collector.description[i].language];
      if (descriptionLabel == null) {
        throw ("Description language could not be resolved");
      }
      descriptionLabel += " description";

      list.add(Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          child: SizedBox(
              height: 140,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.only(bottom: 1),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (i != 0)
                        IconButton(
                          onPressed: () {
                            if (collector.description[i].content != "") {
                              showDialog(
                                  // "Are you sure" dialog
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        title: const Text("Delete Description"),
                                        content: Text(
                                            "Are you sure you want to delete this ${data.languages[collector.description[i].language]!.toLowerCase()} description? It contains text."),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                            },
                                            child: const Text("No"),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                collector.description
                                                    .removeAt(i);
                                              });
                                              Navigator.of(ctx).pop();
                                            },
                                            child: const Text("Yes"),
                                          ),
                                        ],
                                      ));
                            } else {
                              setState(() {
                                collector.description.removeAt(i);
                              });
                            }
                          },
                          icon: const Icon(Icons.close),
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
                            true, // TODO when i remove this, dropdown isnt aligned with textfield, but better looking
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
        children: const [
          Icon(Icons.add),
          Text("Add another language"),
        ],
      ),
    ));

    return list;
  }
}

class MediaTitleWidget extends StatefulWidget {
  const MediaTitleWidget({Key? key}) : super(key: key);

  @override
  _MediaTitleWidget createState() => _MediaTitleWidget();
}

class _MediaTitleWidget extends State<MediaTitleWidget> {
  bool _isChecking = false;
  String? _validationMsg;
  InformationCollector collector = InformationCollector();

  @override
  Widget build(BuildContext context) {
    if (collector.images.length > 1) {
      // If this is a batch upload
      return Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) _validateBatch();
                  },
                  child: TextFormField(
                      controller: TextEditingController(
                        text: collector.fileName,
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => _validationMsg,
                      onChanged: (value) {
                        collector.fileName = value;
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.file_copy_outlined),
                        labelText: 'File Name Schema',
                        hintText: 'Choose a descriptive name',
                        suffixIcon: _isChecking
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator())
                            : null,
                      ))),
              if (collector.fileName != null && collector.fileName!.isNotEmpty)
                Card(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: SizedBox(
                        width: double.infinity,
                        child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    const Text("Generated File Names:",
                                        style: text_styles.objectDescription),
                                    Column(
                                      children: List<Widget>.generate(
                                          collector.images.length, (index) {
                                        return Text(
                                          collector.fileName! +
                                              "_" +
                                              (index + 1).toString() +
                                              collector.fileType!,
                                          style: text_styles.hintText,
                                        );
                                      }),
                                    )
                                  ],
                                ),
                                const InfoPopUp(
                                    "As you are uploading multiple files, multiple file names need to be generated. Descriptions, Categories and Licences will be applied to all images uploaded.")
                              ],
                            ))))
            ],
          ));
    } else {
      return Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) _validateSingleName();
                },
                child: TextFormField(
                  controller: TextEditingController(
                    text: collector.fileName,
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (val) => _validationMsg,
                  onChanged: (value) {
                    collector.fileName = value;
                  },
                  decoration: InputDecoration(
                    icon: const Icon(Icons.file_copy_outlined),
                    labelText: 'File Name',
                    hintText: 'Choose a descriptive name',
                    suffixIcon: _isChecking
                        ? Transform.scale(
                            scale: 0.5,
                            child: const CircularProgressIndicator())
                        : null,
                  ),
                ),
              ),
            ),
            if (collector.fileType != null)
              Padding(
                padding: const EdgeInsets.only(right: 8, left: 8, top: 16),
                child: Text(collector.fileType!,
                    style: Theme.of(context).textTheme.subtitle1),
              ),
          ],
        ),
      );
    }
  }

  _validateSingleName() async {
    String? input = collector.fileName;
    String? fileExtension = collector.fileType;
    if (input == null || input.isEmpty) {
      return null;
    }
    if (fileExtension == null || fileExtension.isEmpty) {
      return "Select an image to upload.";
    }
    setState(() {
      _isChecking = true;
    });
    var value = await FilenameCheckService().fileExists(input, fileExtension);
    if (value) {
      _validationMsg = "A file with this title already exists.";
    } else {
      _validationMsg = null;
    }
    setState(() {
      _isChecking = false;
    });
  }

  _validateBatch() async {
    String? input = collector.fileName;
    String fileExtension = collector.fileType!;
    int numberOfImages = collector.images.length;
    bool alreadyExists = false;

    if (input == null || input.isEmpty) {
      return null;
    }
    setState(() {
      _isChecking = true;
    });
    for (int i = 0; i < numberOfImages; i++) {
      var value = await FilenameCheckService()
          .fileExists(input + "_" + (i + 1).toString(), fileExtension);
      if (value) alreadyExists = true;
    }
    if (alreadyExists) {
      _validationMsg = "One of the generated file names already exist.";
    } else {
      _validationMsg = null;
    }
    setState(() {
      _isChecking = false;
    });
  }
}
