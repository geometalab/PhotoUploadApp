import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:projects/controller/wiki/categoryService.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/style/themes.dart';
import 'package:projects/style/textStyles.dart' as customStyles;

class SelectItemFragment extends StatefulWidget {
  // If 0, uses categories / if 1, uses depicts
  // yes ik its ugly, feel free to rewrite
  final int useCase;
  const SelectItemFragment(this.useCase);

  @override
  _SelectItemFragmentState createState() => _SelectItemFragmentState();
}

class _SelectItemFragmentState extends State<SelectItemFragment> {
  CategoryService cs = new CategoryService();
  InformationCollector collector = new InformationCollector();
  List<String>? titles;
  List<Map<String, dynamic>?>? thumbs;
  int? useCase;
  TextEditingController? _typeAheadController;

  @override
  Widget build(BuildContext context) {
    useCase = widget.useCase;

    if (useCase != 0 && useCase != 1) {
      throw ("Incorrect useCase param on StatefulSelectCategoryFragment");
    }

    if (useCase == 0) {
      titles = collector.categories;
      thumbs = collector.categoriesThumb;
    } else {
      titles = collector.depictions;
      thumbs = collector.depictionsThumb;
    }

    // TODO add help menu
    String prefillContent;
    if (collector.preFillContent != null && useCase == 0) {
      prefillContent = collector.preFillContent!;
    } else {
      prefillContent = "";
    }
    _typeAheadController = TextEditingController(text: prefillContent);
    collector.preFillContent =
        null; // Empty prefill content or it will appear again after selection

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
                    labelText: labelText(useCase!),
                    border: OutlineInputBorder())),
            suggestionsCallback: (pattern) async {
              return await cs.getSuggestions(pattern, useCase!);
            },
            itemBuilder: (context, Map<String, dynamic> suggestion) {
              return ListTile(
                // TODO Add Wiki ID in List tile
                title: Text(suggestion['title']!),
                subtitle: Text('${suggestion['id']}'),
              );
            },
            onSuggestionSelected: (Map<String, dynamic> suggestion) {
              setState(() {
                bool duplicate = isDuplicate(suggestion['title'], useCase!);
                if (!duplicate) {
                  if (useCase == 0) {
                    collector.categories.add(suggestion['title']!);
                    collector.categoriesThumb.add(suggestion['thumbnail']);
                    SettingsManager().addToCachedCategories(suggestion);
                  } else {
                    collector.depictions.add(suggestion['title']!);
                    collector.depictionsThumb.add(suggestion['thumbnail']);
                    SettingsManager().addToCachedCategories(suggestion);
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "This item has already been added",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                    backgroundColor: Theme.of(context).errorColor,
                  ));
                }
              });
            },
          )),
      list()
    ]);
  }

  String labelText(int useCase) {
    if (useCase == 0) {
      return "Enter fitting categories";
    } else {
      return "What is depicted on the image?";
    }
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

  Widget list() {
    if (titles!.isEmpty) {
      return Expanded(
        child: Center(
          child: Padding(
              padding: EdgeInsets.fromLTRB(40, 0, 40, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.list,
                    size: 40,
                    color: Colors.grey,
                  ),
                  Text(
                    "Add a category to describe your uploaded image.",
                    textAlign: TextAlign.center,
                    style: customStyles.hintText,
                  )
                ],
              )),
        ),
      );
    } else {
      return Expanded(
        child: ListView.builder(
          itemCount: titles?.length,
          shrinkWrap: true,
          padding: EdgeInsets.all(4),
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                leading: Padding(
                  padding: EdgeInsets.only(top: 6, bottom: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: thumbnail(thumbs![i]),
                  ),
                ),
                title: Text(titles![i]), // TODO Text all on same vertical line
                trailing: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      _typeAheadController?.clear();
                      if (useCase == 0) {
                        collector.categories.removeAt(i);
                        collector.categoriesThumb.removeAt(i);
                      } else {
                        collector.depictions.removeAt(i);
                        collector.depictionsThumb.removeAt(i);
                      }
                    });
                  },
                ),
              ),
            );
          },
        ),
      );
    }
  }

  bool isDuplicate(String title, int useCase) {
    if (useCase == 0) {
      return collector.categories.any((element) => element == title);
    } else {
      return collector.depictions.any((element) => element == title);
    }
  }
}
