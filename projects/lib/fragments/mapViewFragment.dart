import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:projects/api/nearbyCategoriesService.dart';



class StatefulMapFragment extends StatefulWidget {
  @override
  _MapFragment createState() => _MapFragment();
}



class _MapFragment extends State<StatefulMapFragment> {
  List<Marker> markerList = List.empty(growable: true);
  bool firstInit = true;
  MapController mapController = new MapController();
  NearbyCategoriesService ncs = new NearbyCategoriesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
            controller: mapController,
            center: LatLng(46.8, 8.22), // TODO Start on users Location
            zoom: 8.0,
            plugins: <MapPlugin>[
              LocationMarkerPlugin(),
            ]),
        layers: [
          TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
          LocationMarkerLayerOptions(),
          MarkerLayerOptions(
            markers: _getMarkerList(),
          ),
        ],
      ),
      floatingActionButton: new FloatingActionButton.extended(
        onPressed: () {
          this.setState(() {
            ncs.markerBuilder(ncs.getNearbyCategories(mapController.center.latitude, mapController.center.longitude, calculateRadius())).then((value) {
              markerList = value;
            });
          });
        },
        label: Text("Search in this area"),
        icon: Icon(Icons.search),
      ),
    );
  }

  int calculateRadius() {
    // TODO Implement
    return 4;
  }

  List<Marker> _getMarkerList () {
    if(!firstInit){
      List<Marker> returnValue = List.empty(growable: true);
      (ncs.markerBuilder(ncs.getNearbyCategories(mapController.center.latitude, mapController.center.longitude, calculateRadius()))).then((value) {
        returnValue = value;
      });
      print(returnValue.toString());
      return markerList;
    }else{
      firstInit = false;
      return List<Marker>.empty();
    }


  }
}
