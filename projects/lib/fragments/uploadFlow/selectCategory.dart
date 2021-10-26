import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projects/api/categoryService.dart';
import '../commonsUploadFragment.dart';

// TODO display some text in lower half when no category has been added

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
    String prefillContent;
    if (collector.preFillContent != null) {
      prefillContent = collector.preFillContent!;
    } else {
      prefillContent = "";
    }
    final TextEditingController _typeAheadController =
        TextEditingController(text: prefillContent);

    return Column(children: <Widget>[
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
                style: TextStyle(
                    height: 1,
                    fontSize: 20,
                    color: Theme.of(context).textTheme.bodyText1!.color),
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
              setState(() {
                collector.categories.add(suggestion['title']!);
                collector.categoriesThumb.add(suggestion['thumbnail']);
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
                leading: thumbnail(collector.categoriesThumb[i]),
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
    ]);
  }

  Widget thumbnail(Map? thumbnail) {
    if (thumbnail == null) {
      return Container(
        width: 100,
        height: 60,
        color: Colors.grey,
      );
    } else {
      return Image.network(thumbnail['url']);
    }
  }
}
