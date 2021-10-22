import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projects/api/categoryService.dart';

import '../commonsUploadFragment.dart';

class StatefulSelectCategoryFragment extends StatefulWidget {
  @override
  _SelectCategoryFragment createState() => _SelectCategoryFragment();
}

class _SelectCategoryFragment extends State<StatefulSelectCategoryFragment> {
  CategoryService cs = new CategoryService();
  InformationCollector collector = new InformationCollector();

  @override
  Widget build(BuildContext context) {
    // TODO add help menu
    // TODO text in dark mode not readable color
    String prefillContent;
    if (collector.preFillContent != null) {
      prefillContent = collector.preFillContent!;
    } else {
      prefillContent = "";
    }
    final TextEditingController _typeAheadController =
    TextEditingController(text: prefillContent);

    return Expanded(
        child: Column(children: <Widget>[
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
                    collector.categories.add(suggestion['title']!);
                    collector.categoriesThumb.add(Icons.fireplace);
                  });
                },
              )),
          Expanded(
            child: ListView.builder(
              itemCount: collector.categories.length,
              shrinkWrap: true,
              padding: EdgeInsets.all(5),
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int i) {
                return Card(
                  child: ListTile(
                    leading: Icon(collector.categoriesThumb[i]),
                    title: Text(collector.categories[i]),
                    trailing: Icon(Icons.remove),
                    onTap: () {
                      setState(() {
                        _typeAheadController.clear();
                        collector.categories.removeAt(i);
                        collector.categoriesThumb.removeAt(i);
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