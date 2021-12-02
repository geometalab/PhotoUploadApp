import 'dart:convert';
import 'package:http/http.dart';
import 'package:projects/controller/internal/settingsManager.dart';

class CategoryService {
  Future<List<Map<String, dynamic>>> getSuggestions(
      String pattern, int useCase) async {
    var listedSuggestions;
    String request =
        'https://api.wikimedia.org/core/v1/commons/search/title?q=' +
            pattern +
            '&limit=20';
    try {
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
    } catch (e) {
      throw ("Error while getting autocomplete results from Wikimedia: $e");
    }
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
    return new Future.value(suggestionsList);
  }

  List<Map<String, dynamic>> recentlyUsedCategories() {
    List<Map<String, dynamic>> cacheList =
        SettingsManager().getCachedCategories() ?? List.empty();
    List<Map<String, dynamic>> returnList = List.empty(growable: true);
    for (Map<String, dynamic> map in cacheList) {
      returnList.add({
        "title": map["category"],
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
    this.pages = json["pages"] == null
        ? null
        : (json["pages"] as List).map((e) => Pages.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pages != null)
      data["pages"] = this.pages?.map((e) => e.toJson()).toList();
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
    this.id = json["id"];
    this.key = json["key"];
    this.title = json["title"];
    this.excerpt = json["excerpt"];
    this.description = json["description"];
    this.thumbnail = json["thumbnail"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["key"] = this.key;
    data["title"] = this.title;
    data["excerpt"] = this.excerpt;
    data["description"] = this.description;
    data["thumbnail"] = this.thumbnail;
    return data;
  }
}