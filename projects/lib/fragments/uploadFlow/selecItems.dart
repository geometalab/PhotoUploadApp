import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projects/api/categoryService.dart';
import 'package:projects/style/themes.dart';
import '../commonsUploadFragment.dart';

// TODO display some text in lower half when no category has been added

class StatefulSelectItemFragment extends StatefulWidget {
  // If 0, uses categories / if 1, uses depicts
  // yes ik its ugly, feel free to rewrite
  final int useCase;
  const StatefulSelectItemFragment(this.useCase);

  @override
  _SelectItemFragment createState() => _SelectItemFragment();
}

class _SelectItemFragment extends State<StatefulSelectItemFragment> {
  CategoryService cs = new CategoryService();
  InformationCollector collector = new InformationCollector();

  @override
  Widget build(BuildContext context) {
    final useCase = widget.useCase;
    if (useCase != 0 && useCase != 1) {
      throw ("Incorrect useCase param on StatefulSelectCategoryFragment");
    }
    List<String> titles;
    List<Map<String, dynamic>?> thumbs;
    if (useCase == 0) {
      titles = collector.categories;
      thumbs = collector.categoriesThumb;
    } else {
      titles = collector.depicts;
      thumbs = collector.depictsThumb;
    }

    // TODO add help menu
    String prefillContent;
    if (collector.preFillContent != null && useCase == 0) {
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
                    labelText: "Enter fitting keywords", // TODO maybe change this per useCase
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
                if (useCase == 0) {
                  collector.categories.add(suggestion['title']!);
                  collector.categoriesThumb.add(suggestion['thumbnail']);
                } else {
                  collector.depicts.add(suggestion['title']!);
                  collector.depictsThumb.add(suggestion['thumbnail']);
                }
              });
            },
          )),
      Expanded(
        child: ListView.builder(
          itemCount: titles.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(4),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              child: ListTile(
                leading: Padding(
                  padding: EdgeInsets.all(6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: thumbnail(thumbs[i]),
                  ),
                ),
                title: Text(titles[i]), // TODO Text all on same vertical line
                trailing: Icon(Icons.remove),
                onTap: () {
                  setState(() {
                    _typeAheadController.clear();
                    if (useCase == 0) {
                      collector.categories.removeAt(i);
                      collector.categoriesThumb.removeAt(i);
                    } else {
                      collector.depicts.removeAt(i);
                      collector.depictsThumb.removeAt(i);
                    }
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
        color: CustomColors.NO_IMAGE_COLOR,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Icon(Icons.image_not_supported,
              color: CustomColors.NO_IMAGE_CONTENTS_COLOR),
        ),
      );
    } else {
      return Image.network(thumbnail['url']);
    }
  }
}
