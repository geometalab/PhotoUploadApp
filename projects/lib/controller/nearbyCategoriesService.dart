import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

class NearbyCategoriesService {
  Future<List<CategoryLocation>> getNearbyCategories(
      double lat, double lng, int radius) async {
    String url =
        await rootBundle.loadString('assets/queries/minNearbyCategories.url');
    url = url.replaceAll('{lng}', lng.toString());
    url = url.replaceAll('{lat}', lat.toString());
    url = url.replaceAll('{rad}', radius.toString());
    final response = await get(Uri.parse(url));

    if (response.statusCode == 200) {
      XmlDocument xml = XmlDocument.parse(response.body);
      var xmlList = xml
          .getElement("sparql")!
          .getElement("results")!
          .findAllElements("result")
          .toList();
      List<CategoryLocation> resultList = List.empty(growable: true);
      for (int i = 0; i < xmlList.length; i++) {
        // Very sloppy way of extracting from xml by searching for keys in a string and then using substring to extract data
        String resultString = xmlList[i].toXmlString(pretty: true);
        int coordinateStartIndex = resultString.indexOf("Point(");
        int coordinateEndIndex = resultString.indexOf(")<");
        int stringStartIndex = resultString.lastIndexOf("<literal>");
        int stringEndIndex = resultString.indexOf("<", stringStartIndex + 1);

        var coordinateString = resultString.substring(
            coordinateStartIndex + 6, coordinateEndIndex);
        var commonsString =
            resultString.substring(stringStartIndex + 9, stringEndIndex);

        var lat = coordinateString.split(" ")[0];
        var lng = coordinateString.split(" ")[1];

        if (!resultList
            .any((CategoryLocation cl) => cl.commons == commonsString)) {
          resultList.add(new CategoryLocation(
              commonsString, double.parse(lng), double.parse(lat)));
        }
      }
      return resultList;
    } else {
      throw "Couldn't get nearest Items from Wikimedia Query. Status Code " +
          response.statusCode.toString();
    }
  }

  Future<List<Marker>> markerBuilder(
      Future<List<CategoryLocation>> locationList, BuildContext context) async {
    List<CategoryLocation> locations = await locationList;
    List<Marker> markers = [];
    for (int i = 0; i < locations.length; i++) {
      markers.add(
        Marker(
          width: 40,
          height: 40,
          anchorPos: AnchorPos.align(AnchorAlign.top),
          rotateAlignment: Alignment(0, 0.8),
          point: LatLng(locations[i].lat, locations[i].lng),
          builder: (ctx) => Container(
              child: Icon(Icons.location_pin,
                  color: Theme.of(context).colorScheme.primary, size: 40)),
          key: new Key(locations[i].commons),
          rotate: true,
        ),
      );
    }
    return markers;
  }
}

class CategoryLocation {
  double lat;
  double lng;
  String commons;

  CategoryLocation(this.commons, this.lat, this.lng);
}
