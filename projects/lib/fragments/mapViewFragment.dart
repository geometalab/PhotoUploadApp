import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projects/MapPopUps/categoryMapPopup.dart';
import 'package:projects/api/nearbyCategoriesService.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import'dart:math' as Math;



class StatefulMapFragment extends StatefulWidget {
  @override
  _MapFragment createState() => _MapFragment();
}



class _MapFragment extends State<StatefulMapFragment> {

  // TODO make it impossible to zoom out so far that background of fragment can be seen

  List<Marker> _markerList = List.empty(growable: true);

  final MapController mapController = new MapController();
  final NearbyCategoriesService ncs = new NearbyCategoriesService();
  final PopupController _popupLayerController = PopupController();


  // TODO Implement a "fix the map button" as recommended by osm (https://operations.osmfoundation.org/policies/tiles/)
  @override
  Widget build(BuildContext context) {

    getStartPosition().then((latLng) { // Center on position if available
      if(latLng != null){
        mapController.move(latLng, 14);
      }
    });

    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            onTap: (tapPosition, latLng) => _popupLayerController.hidePopup(),
            controller: mapController,
            center: LatLng(46.8, 8.22), // Starting pos when gps access is denied
            zoom: 8.0,
            enableMultiFingerGestureRace: true,
            minZoom: 2,
            maxZoom: 18,
            enableScrollWheel: true,
            plugins: <MapPlugin>[
              LocationMarkerPlugin(),
              MarkerClusterPlugin()
            ]),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // TODO maybe get a maptiler key for better map themes (and dark theme)
            subdomains: ['a', 'b', 'c']),
        LocationMarkerLayerOptions(),
        MarkerClusterLayerOptions(
          // TODO get markers to rotate as well
          popupOptions: PopupOptions(
              popupBuilder: (BuildContext context, Marker marker) => CategoryPopup(marker),
              popupController: _popupLayerController,
              markerRotate: true,
          ),
          builder: (BuildContext context, List<Marker> markers) {
            return FloatingActionButton(
              child: Text(markers.length.toString()),
              onPressed: () {
                mapController.fitBounds(getMarkerListMiddle(markers)); // TODO when in very high zoom, clicking a cluster button doesn't zoom anymore, which it still should
              },
              heroTag: "clusterBtn",
            );
          },
          markers: getMarkerList(),
          maxClusterRadius: 120,
          size: Size(40, 40),
          fitBoundsOptions: FitBoundsOptions(
            padding: EdgeInsets.all(50),
          ),
        ),
      ]),
      floatingActionButton: new FloatingActionButton.extended(
        onPressed: () {
          ncs.markerBuilder(ncs.getNearbyCategories(mapController.center.latitude, mapController.center.longitude, calculateKmRadius())).then((value) {
            _markerList = value;
            setState(() {});
          });
        },
        label: Text("Search in this area"),
        icon: Icon(Icons.search),
        heroTag: "searchBtn",
      ),
    );
  }

  int calculateKmRadius() {
    // Resources:
    // https://wiki.openstreetmap.org/wiki/Zoom_levels
    // https://en.wikipedia.org/wiki/Haversine_formula

    // Zoom lvl | distance from nw / se (measured manually)
    // 12 | 17 km
    // 13 | 9.5 km
    // 15 | 3.4 km
    // 17 | 0.766

    if(mapController.zoom > 17.0){
      return 1;
    } else if (mapController.zoom > 15.0) {
      return 3;
    } else if (mapController.zoom > 13){
      return 5;
    } else {
      return 8;
    }
  }

  Future<LatLng?> getStartPosition() async{ // TODO position still has some delay, improve for later
    final LatLng? latLng;
    final permission = await Geolocator.checkPermission();
      if(permission == LocationPermission.always || permission == LocationPermission.whileInUse){
        Position pos = await Geolocator.getCurrentPosition();
        latLng = LatLng(pos.latitude, pos.longitude);
      }else{
        latLng = null;
      }
      return latLng;
  }


  List<Marker> getMarkerList () {
    return _markerList;
  }

  LatLngBounds getMarkerListMiddle(List<Marker> markers) {
    double minLat = 1000, maxLat = -1000, minLng = 1000, maxLng = -1000;
    for(Marker marker in markers) {
      if(marker.point.latitude < minLat){ minLat = marker.point.latitude; }
      if(marker.point.latitude > maxLat){ maxLat = marker.point.latitude; }
      if(marker.point.longitude < minLng){ minLng = marker.point.longitude; }
      if(marker.point.longitude > maxLng){ maxLng = marker.point.longitude; }
    }
    double margin = (maxLng - minLng) / 10;
    return LatLngBounds.fromPoints([LatLng(maxLat + margin, minLng - margin), LatLng(minLat - margin, maxLng + margin)]);
  }

}
