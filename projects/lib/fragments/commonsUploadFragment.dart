import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/api/categoryService.dart';

// TODO check if process still works when going back one fragment (no errors, correct data still filled in etc.)


class SelectImageFragment extends StatelessWidget {
  //TODO? Support Video Files?
  //TODO? Support Audio Files?
  //TODO? Support multiple Files?

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(2),
              child: ElevatedButton(
                onPressed: () async {
                  InformationCollector.image = await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => StatefulSelectCategoryFragment()),
                  );
                },
                  child: SizedBox(
                    width: 200,
                    height: 40,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget> [
                          Icon(Icons.file_copy_outlined),
                          Padding(padding: EdgeInsets.only(left: 5)),
                          Text("Select Image from Files"),
                        ]
                    ),
                  )
              ),
            ),
            Padding(
                padding: EdgeInsets.all(2),

                child: ElevatedButton(
                  onPressed: () async {
                    InformationCollector.image = await _picker.pickImage(source: ImageSource.camera);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StatefulSelectCategoryFragment()),
                    );
                  },
                    child: SizedBox(
                      width: 200,
                      height: 40,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget> [
                            Icon(Icons.camera_alt_outlined),
                            Padding(padding: EdgeInsets.only(left: 5)),
                            Text("Capture a Photo"),
                          ]
                      ),
                    )
                )
            )
          ],
      )
    );
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

  @override
  Widget build(BuildContext context) {
    String prefillContent;
    if(InformationCollector.preFillContent != null) {
      prefillContent = InformationCollector.preFillContent!;
    } else {
      prefillContent = "";
    }
    final TextEditingController _typeAheadController = TextEditingController(text: prefillContent);
    addedCategories = InformationCollector.imageCategories;

    return new Scaffold(
        body: Column(children: <Widget>[
          AppBar(
            title: Text('Add Categories'),
            actions: [
              IconButton(onPressed: () {
                InformationCollector.imageCategories = addedCategories;
                Navigator.push(context, MaterialPageRoute(
                    builder: (context) => StatefulInformationFragment()),
                );
              }
              , icon: Icon(Icons.done), color: Colors.white),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
              )
            ],
          ),
          Padding(padding: EdgeInsets.all(2)),
          Padding(
              padding: EdgeInsets.all(10),

              // Autocomplete field which suggests existing Wikimedia categories and gets their Wikidata IDs. Documentation: https://pub.dev/documentation/flutter_typeahead/latest/
              child: TypeAheadField(
                debounceDuration: Duration(milliseconds: 150), // Wait for 150 ms of no typing before starting to get the results
                textFieldConfiguration: TextFieldConfiguration(
                    controller: _typeAheadController,
                    autofocus: true,
                    style: TextStyle(
                      height: 1,
                      fontSize: 20,
                      color: Colors.black
                    ),
                    decoration: InputDecoration(
                        labelText: "Enter fitting Keywords",
                        border: OutlineInputBorder()
                    )
                ),
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
              )
          ),
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
        ]
      )
    );
  }
}

class StatefulInformationFragment extends StatefulWidget {
  @override
  _InformationFragment createState() => _InformationFragment();
}

class _InformationFragment extends State<StatefulInformationFragment> {

  DateTime selectedDate = DateTime.now();
  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1, 1),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Find field info here: https://commons.wikimedia.org/wiki/Template:Information
  // TODO implement source
  // TODO implement permission
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: ListView(
            children: <Widget>[
              AppBar(
                title: Text('Enter File Details'),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.file_copy_outlined),
                      labelText: 'File Name',
                      hintText: 'Choose a descriptive name',
                    )
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child:
                TextFormField(
                    decoration: const InputDecoration(
                      icon: Icon(Icons.text_fields_outlined),
                      labelText: 'Description',
                      hintText: 'Write a meaningful description',
                      contentPadding: const EdgeInsets.only(bottom: 100),
                    )
                ),
              ),
              Padding(padding: EdgeInsets.all(10),
                child: TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Author',
                    hintText: 'Original author of the file'
                  )
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey,),
                          Padding(padding: EdgeInsets.only(left: 18)),
                          Text('Date:', textScaleFactor: 1.2, style: TextStyle(color: Colors.grey[700]),),
                        ],),
                    ),
                    Container(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${selectedDate.toLocal()}".split(' ')[0], textScaleFactor: 1.2,),
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
              Padding(padding: EdgeInsets.all(10),
                child: SizedBox(
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () {
                      //TODO Implement with API
                    },
                    child: Text('Submit to Commons'),
                  )
                )
              ),
            ]
        )
    );
  }



}

class InformationCollector {
  static XFile? image;
  static List<String> imageCategories = List.empty(growable: true);
  static String? preFillContent; // Is loaded into typeahead field
}


