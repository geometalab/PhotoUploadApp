import 'dart:collection';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';


class CategoryService{

  Future<List<Map<String, dynamic>>> getSuggestions(String pattern) async {
    var listedSuggestions;
    try{
      if (pattern.isEmpty || pattern.length < 3) {
        return Future.value([]); // Search Results only start to get shown after 3 entered chars
      }
      String request = 'https://api.wikimedia.org/core/v1/wikipedia/en/search/title?q=' + pattern + '&limit=3';
      Response response = await get(Uri.parse(request));
      var jsonObject = jsonDecode(response.body);
      var suggestions = jsonObject[0];
      LinkedHashMap temp = jsonObject;
      suggestions = temp.entries.toList(growable: true);
      MapEntry tempMap = suggestions[0];
      List tempList = tempMap.value;
      print(tempList);
      listedSuggestions = tempList.map((e) => {'title': e['title'], 'id': e['id']}).toList() ;
      print(listedSuggestions.toString());
    }catch (e){
      print(e);
    }
    return new Future.value(listedSuggestions);
  }
  /*
  Future<List<Map<String, String>>> getSuggestions(String pattern) async {
    if (pattern.isEmpty && pattern.length < 3) {
      return Future.value([]); // Search Results only start to get shown after 3 entered chars
    }
    String request = 'https://api.wikimedia.org/core/v1/wikipedia/en/search/title?q=' + pattern + '&limit=3';
    Response response = await get(Uri.parse(request));
    List<Suggestion> suggestions = [];
    if (response.statusCode == 200) {
      print("3");
      print(response.body);
      var jsonObject = jsonDecode(response.body);
      print("1");
      suggestions = List<Suggestion>.from(jsonObject.map((model)  {
        print("4");
        return Suggestion.fromJson(model);
      }));
      print("2");
    } else {
      throw ErrorSummary("Could not get search results.");
    }
    return Future.value(suggestions.map((e) => {'title': e.title, 'tag': e.tag.toString()}).toList());
  }
   */


}
class Suggestion {
  List<Pages>? pages;

  Suggestion({this.pages});

  Suggestion.fromJson(Map<String, dynamic> json) {
    this.pages = json["pages"]==null ? null : (json["pages"] as List).map((e)=>Pages.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if(this.pages != null)
      data["pages"] = this.pages?.map((e)=>e.toJson()).toList();
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

  Pages({this.id, this.key, this.title, this.excerpt, this.description, this.thumbnail});

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


