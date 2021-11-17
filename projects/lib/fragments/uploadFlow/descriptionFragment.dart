import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/model/datasets.dart' as data;
import 'package:projects/style/themes.dart';
import '../commonsUploadFragment.dart';

class DescriptionFragment extends StatefulWidget {
  @override
  _DescriptionFragment createState() => _DescriptionFragment();
}

class _DescriptionFragment extends State<DescriptionFragment> {
  // TODO maybe the image should be shown at the top here, so user can have a look at it when making description
  InformationCollector collector = new InformationCollector();

  @override
  Widget build(BuildContext context) {
    return Container(
        child: SingleChildScrollView(
            child: Column(children: descriptionWidgets())));
  }

  List<Widget> descriptionWidgets() {
    List<Widget> list = new List.empty(growable: true);
    list.add(mediaTitleWidget());
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
      collector.description.add(Description(language: "en"));
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

  Widget mediaTitleWidget() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextFormField(
              initialValue: collector.fileName,
              onChanged: (value) {
                collector.fileName = value;
              },
              // TODO check file name for illegal chars, maybe enforce min and max length
              decoration: const InputDecoration(
                icon: Icon(Icons.file_copy_outlined),
                labelText: 'File Name',
                hintText: 'Choose a descriptive name',
              ),
            ),
          ),
          if (collector.fileType != null)
            Padding(
              padding: EdgeInsets.only(right: 8, left: 8, top: 16),
              child: Text(collector.fileType!,
                  style: Theme.of(context).textTheme.subtitle1),
            ),
        ],
      ),
    );
  }
}

class Description {
  String language;
  String content;

  Description({this.language = "en", this.content = ""});
}
