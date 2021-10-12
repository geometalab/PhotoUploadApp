import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/api/categoryService.dart';
import 'package:projects/api/loginHandler.dart';
import 'package:projects/api/uploadService.dart';
import 'dart:io';

import 'package:projects/fragments/singlePage/loggedOut.dart';

// TODO check if process still works when going back one fragment (no errors, correct data still filled in etc.)

class SelectImageFragment extends StatelessWidget {
  // TODO to have a full screen, just for two buttons is way to much space (idk how to fix)
  //TODO? Support Video Files?
  //TODO? Support Audio Files?
  //TODO? Support multiple Files?

  final ImagePicker _picker = ImagePicker();
  final InformationCollector collector = new InformationCollector();


  @override
  Widget build(BuildContext context) {
    if (true) {
      return loggedOut().screen(context);
    } else {
      return new Scaffold(
          backgroundColor: Theme
              .of(context)
              .canvasColor,
          body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(2),
                    child: ElevatedButton(
                        onPressed: () async {
                          InformationCollector.image =
                          await _picker.pickImage(source: ImageSource.gallery);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    StatefulSelectCategoryFragment()),
                          );
                        },
                        child: SizedBox(
                          width: 200,
                          height: 40,
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.file_copy_outlined),
                                Padding(padding: EdgeInsets.only(left: 5)),
                                Text("Select Image from Files"),
                              ]),
                        )),
                  ),
                  Padding(
                      padding: EdgeInsets.all(2),
                      child: ElevatedButton(
                          onPressed: () async {
                            InformationCollector.image =
                            await _picker.pickImage(source: ImageSource.camera);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      StatefulSelectCategoryFragment()),
                            );
                          },
                          child: SizedBox(
                            width: 200,
                            height: 40,
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.camera_alt_outlined),
                                  Padding(padding: EdgeInsets.only(left: 5)),
                                  Text("Capture a Photo"),
                                ]),
                          )))
                ],
              )));
    }
  }
}

class StatefulSelectCategoryFragment extends StatefulWidget {
  @override
  _SelectCategoryFragment createState() => _SelectCategoryFragment();
}

class _SelectCategoryFragment extends State<StatefulSelectCategoryFragment> {
  List<String> addedCategories = [];
  List<IconData> addedCategoriesImages = [];
  CategoryService cs = new CategoryService();
  InformationCollector collector = new InformationCollector();

  @override
  Widget build(BuildContext context) {
    // TODO text in dark mode not readable color
    String prefillContent;
    if (collector.preFillContent != null) {
      prefillContent = collector.preFillContent!;
    } else {
      prefillContent = "";
    }
    final TextEditingController _typeAheadController =
        TextEditingController(text: prefillContent);
    addedCategories = collector.imageCategories;

    return new Scaffold(
        body: Column(children: <Widget>[
      AppBar(
        title: Text('Add Categories'),
        actions: [
          IconButton(
              onPressed: () {
                collector.imageCategories = addedCategories;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StatefulInformationFragment()),
                );
              },
              icon: Icon(Icons.done),
              color: Colors.white),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
          )
        ],
      ),
      Padding(padding: EdgeInsets.all(2)),
      Padding(
          padding: EdgeInsets.all(8),
          // Autocomplete field which suggests existing Wikimedia categories and gets their Wikidata IDs. Documentation: https://pub.dev/documentation/flutter_typeahead/latest/
          child: TypeAheadField(
            debounceDuration: Duration(
                milliseconds:
                    150), // Wait for 150 ms of no typing before starting to get the results
            textFieldConfiguration: TextFieldConfiguration(
                controller: _typeAheadController,
                autofocus: true,
                style: TextStyle(height: 1, fontSize: 20, color: Colors.black),
                decoration: InputDecoration(
                    labelText: "Enter fitting keywords",
                    border: OutlineInputBorder())),
            suggestionsCallback: (pattern) async {
              return await cs.getSuggestions(pattern);
            },
            itemBuilder: (context, Map<String, dynamic> suggestion) {
              return ListTile(
                title: Text(suggestion['title']!),
                subtitle: Text('${suggestion['id']}'),
              );
            },
            onSuggestionSelected: (Map<String, dynamic> suggestion) {
              // TODO Add Wiki ID in List tile
              // TODO Add Image thumbnail in List tile
              setState(() {
                addedCategories.add(suggestion['title']!);
                addedCategoriesImages.add(Icons.fireplace);
              });
            },
          )),
      Expanded(
        child: ListView.builder(
          itemCount: addedCategories.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(5),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              child: ListTile(
                leading: Icon(addedCategoriesImages[i]),
                title: Text(addedCategories[i]),
                trailing: Icon(Icons.remove),
                onTap: () {
                  setState(() {
                    _typeAheadController.clear();
                    addedCategories.removeAt(i);
                    addedCategoriesImages.removeAt(i);
                  });
                },
              ),
            );
          },
        ),
      )
    ]));
  }
}

class StatefulInformationFragment extends StatefulWidget {
  @override
  _InformationFragment createState() => _InformationFragment();
}

class _InformationFragment extends State<StatefulInformationFragment> {
  InformationCollector collector = new InformationCollector();

  DateTime selectedDate = InformationCollector().date;
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        collector.date = picked;
        selectedDate = picked;
      });
    }
  }

  // Find field info here: https://commons.wikimedia.org/wiki/Template:Information
  // TODO implement additional fields if needed
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: ListView(children: <Widget>[
      AppBar(
        title: Text('Enter File Details'),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
            initialValue: collector.fileName,
            onChanged: (value) {
              collector.fileName = value;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.file_copy_outlined),
              labelText: 'File Name',
              hintText: 'Choose a descriptive name',
            )),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
            initialValue: collector.description,
            onChanged: (value) {
              collector.description = value;
            },
            decoration: const InputDecoration(
              icon: Icon(Icons.text_fields_outlined),
              labelText: 'Description',
              hintText: 'Write a meaningful description',
              contentPadding: const EdgeInsets.only(bottom: 100),
            )),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: TextFormField(
            initialValue: collector.author,
            onChanged: (value) {
              collector.author = value;
            },
            decoration: const InputDecoration(
                icon: Icon(Icons.person),
                labelText: 'Author',
                hintText: 'Original author of the file')),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.description_outlined,
                  color: Colors.grey[600],
                ),
                Padding(padding: EdgeInsets.only(left: 18)),
                Text(
                  "License: ",
                  textScaleFactor: 1.2,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
            DropdownButton<String>(
              value: collector.license,
              onChanged: (String? newValue) {
                setState(() {
                  collector.license = newValue!;
                });
              },
              icon: const Icon(Icons.arrow_downward),
              iconSize: 24,
              elevation: 16,
              underline: Container(
                height: 2,
                color: Theme.of(context).colorScheme.secondary,
              ),
              items: <String>[
                'CC0',
                'Attribution 3.0',
                'Attribution-ShareAlike 3.0',
                'Attribution 4.0',
                'Attribution-ShareAlike 4.0'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey[600],
                  ),
                  Padding(padding: EdgeInsets.only(left: 18)),
                  Text(
                    'Date:',
                    textScaleFactor: 1.2,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Container(
              // TODO date should be on the other side, next to label "Date:"
              child: Row(
                  // TODO make clean bc this shits itself once the resolution is a bit different
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "${selectedDate.toLocal()}".split(' ')[0],
                      textScaleFactor: 1.2,
                    ),
                    Padding(padding: EdgeInsets.only(left: 30)),
                    OutlinedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Select date'),
                    )
                  ]),
            )
          ],
        ),
      ),
      Padding(
          padding: EdgeInsets.all(8),
          child: SizedBox(
              height: 45,
              child: ElevatedButton(
                onPressed: () {
                  InformationCollector().submitData();
                },
                child: Text('Submit to Commons'),
              ))),
    ]));
  }
}

class InformationCollector {
  static final InformationCollector _informationCollector =
      InformationCollector._internal();

  factory InformationCollector() {
    return _informationCollector;
  }

  InformationCollector._internal();

  XFile? image;
  String? fileName;
  List<String> imageCategories = List.empty(growable: true);
  String? preFillContent; // Is loaded into typeahead field
  String? title;
  String? description;
  String? author;
  String? license = 'CC0';
  DateTime date = DateTime.now();

  submitData() {
    try {
      UploadService().uploadImage(
          image!, fileName!, fileName!, description!, author!, license!, date);
    } catch (e) {
      print(e);
    }
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
