import 'dart:convert';
import 'package:http/http.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import '../../model/datasets.dart';

class CategoryService {
  Future<List<Map<String, dynamic>>> getSuggestions(
      String pattern, SelectItemsFragmentUseCase useCase) async {
    List<Map<String, dynamic>> listedSuggestions;
    String request =
        'https://api.wikimedia.org/core/v1/commons/search/title?q=' +
            pattern +
            '&limit=20';

    if (pattern.isEmpty) {
      return Future.value(recentlyUsedCategories());
    } else if (pattern.length < 2) {
      return Future.value(
          []); // Search Results only start to get shown after 2 entered chars
    }
    Response response = await get(Uri.parse(request),
        headers: {'Content-Type': 'application/json'});
    var hashMap = jsonDecode(utf8.decode(response.bodyBytes));
    var suggestions = hashMap.entries.toList(growable: true);
    List tempList = suggestions[0].value;
    listedSuggestions = tempList
        .map((e) =>
            {'title': e['title'], 'id': e['id'], 'thumbnail': e['thumbnail']})
        .toList();

    List<Map<String, dynamic>> suggestionsList = listedSuggestions;
    // Remove all file items
    suggestionsList.removeWhere((element) {
      String title = element['title'];
      return title.startsWith("File:");
    });
    // Remove all "Category:" prefixes.
    for (var suggestion in suggestionsList) {
      if (suggestion['title'].toString().startsWith("Category:")) {
        suggestion['title'] =
            suggestion['title'].toString().replaceFirst("Category:", "");
      }
    }
    return Future.value(suggestionsList);
  }

  List<Map<String, dynamic>> recentlyUsedCategories() {
    List<Map<String, dynamic>> cacheList =
        SettingsManager().getCachedCategories() ?? List.empty();
    List<Map<String, dynamic>> returnList = List.empty(growable: true);
    for (Map<String, dynamic> map in cacheList) {
      returnList.add({
        "title": map["title"],
        "id": "Recently used",
        "thumbnail": map["thumbnail"],
      });
    }
    return returnList;
  }
}

class Suggestion {
  List<Pages>? pages;
  Suggestion({this.pages});

  Suggestion.fromJson(Map<String, dynamic> json) {
    pages = json["pages"] == null
        ? null
        : (json["pages"] as List).map((e) => Pages.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pages != null) {
      data["pages"] = pages?.map((e) => e.toJson()).toList();
    }
    return data;
  }
}

class Pages {
  int? id;
  String? key;
  String? title;
  String? excerpt;
  String? description;
  dynamic thumbnail;

  Pages(
      {this.id,
      this.key,
      this.title,
      this.excerpt,
      this.description,
      this.thumbnail});

  Pages.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    key = json["key"];
    title = json["title"];
    excerpt = json["excerpt"];
    description = json["description"];
    thumbnail = json["thumbnail"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data["id"] = id;
    data["key"] = key;
    data["title"] = title;
    data["excerpt"] = excerpt;
    data["description"] = description;
    data["thumbnail"] = thumbnail;
    return data;
  }
}
