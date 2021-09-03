import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:projects/api/categoryService.dart';
import 'package:xml/xml.dart';

class NearbyCategoriesService{

  Future<List<CategoryLocation>?> getNearbyCategories (double lat, double lng, int radius) async {
    String url = await rootBundle.loadString('assets/queries/minNearbyCategories.url');
    url = url.replaceAll('{lng}', lng.toString());
    url = url.replaceAll('{lat}', lat.toString());
    url = url.replaceAll('{rad}', radius.toString());
    final response = await get(Uri.parse(url));

    if(response.statusCode == 200){
      // TODO Query optimisation => (wikidata.org/wiki/Wikidata:SPARQL_query_service/query_optimization)
      XmlDocument xml = XmlDocument.parse(response.body);
      var xmlList = xml.getElement("sparql")!.getElement("results")!.findAllElements("result").toList();
      List<CategoryLocation> resultList = List.empty(growable: true);
      for(int i = 0; i < xmlList.length; i++){
        String resultString = xmlList[i].toXmlString(pretty: true);
        int coordinateIndex = resultString.indexOf("Point(");
        int stringStartIndex = resultString.lastIndexOf("<literal>");
        int stringEndIndex = resultString.indexOf("<", stringStartIndex + 1);
        var coordinateString = resultString.substring( coordinateIndex + 6, coordinateIndex + 21);
        var commonsString = resultString.substring(stringStartIndex + 9, stringEndIndex);
        resultList.add(new CategoryLocation(commonsString, double.parse(coordinateString.substring(8)), double.parse(coordinateString.substring(0, 7))));
      }
      return resultList;
    }else{
      throw "Couldn't get nearest Items from Wikimedia Query. Status Code " + response.statusCode.toString();
    }
  }
}

class CategoryLocation{
  double lat;
  double lng;
  String commons;

  CategoryLocation (this.commons, this.lat, this.lng);

}