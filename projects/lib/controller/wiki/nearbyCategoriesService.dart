import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../../model/exceptions/requestException.dart';

class NearbyCategoriesService {
  List<CategoryLocation> cacheList = List.empty(growable: true);

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
      cacheMerge(resultList);
      return cacheList;
    } else {
      throw RequestException("Error while getting nearest Items.", response);
    }
  }

  cacheMerge(List<CategoryLocation> fetchedCategories) {
    for (CategoryLocation fetchedLocation in fetchedCategories) {
      bool duplicate = false;
      for (CategoryLocation cachedLocation in cacheList) {
        if (fetchedLocation.equals(cachedLocation)) {
          duplicate = true;
        }
      }
      if (!duplicate) {
        cacheList.add(fetchedLocation);
      }
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

// TODO detect if category already has images, and if not, display on map
class CategoryLocation {
  double lat;
  double lng;
  String commons;

  CategoryLocation(this.commons, this.lat, this.lng);

  bool equals(CategoryLocation categoryLocation) {
    if (this.commons == categoryLocation.commons &&
        this.lng == categoryLocation.lng &&
        this.lat == categoryLocation.lat) {
      return true;
    } else
      return false;
  }
}
