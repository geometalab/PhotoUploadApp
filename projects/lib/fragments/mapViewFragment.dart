import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            // TODO finetune map handling
            onTap: (tapPosition, latLng) => _popupLayerController.hidePopup(),
            controller: mapController,
            center: LatLng(46.8, 8.22), // TODO Start on users Location
            zoom: 8.0,
            plugins: <MapPlugin>[
              LocationMarkerPlugin(),
              MarkerClusterPlugin()
            ]),
      layers: [
        TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // TODO andere osm themes anschauen
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
          ncs.markerBuilder(ncs.getNearbyCategories(mapController.center.latitude, mapController.center.longitude, calculateRadius())).then((value) {
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

  int calculateRadius() {
    // Resources:
    // https://wiki.openstreetmap.org/wiki/Zoom_levels
    // https://en.wikipedia.org/wiki/Haversine_formula

    double _deg2rad(deg) {
      return deg * (Math.pi/180);
    }
    
    double getDistanceFromLatLon(lat1,lon1,lat2,lon2) { // With the haversine formula
      var R = 6371; // Radius of the earth in km
      var dLat = _deg2rad(lat2-lat1);
      var dLon = _deg2rad(lon2-lon1);
      var a =
          Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(_deg2rad(lat1)) * Math.cos(_deg2rad(lat2)) *
                  Math.sin(dLon/2) * Math.sin(dLon/2)
      ;
      var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      var d = R * c; // Distance in km
      return d;
    }



    
    
    return 4;
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
