import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import 'package:projects/view/mapPopUps/category_map_popup.dart';
import 'package:projects/controller/wiki/nearby_categories_service.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'dart:math' as math;

class MapFragment extends StatefulWidget {
  const MapFragment({Key? key}) : super(key: key);

  @override
  _MapFragmentState createState() => _MapFragmentState();
}

class _MapFragmentState extends State<MapFragment> {
  List<Marker> _markerList = List.empty(growable: true);
  LatLng? lastLoadPosition;
  bool isTooFarOut = false;
  int clusterBtnNumber =
      0; // As each ClusterBtn needs their own hero tag, this counter serves to determine the name of each one.

  final MapController _mapController = MapController();
  final NearbyCategoriesService _ncs = NearbyCategoriesService();
  final PopupController _popupLayerController = PopupController();

  // TODO Implement a "fix the map button" as recommended by osm (https://operations.osmfoundation.org/policies/tiles/)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              onTap: (tapPosition, latLng) =>
                  _popupLayerController.hideAllPopups(),
              controller: _mapController,
              center:
                  LatLng(46.8, 8.22), // Starting pos when gps access is denied
              zoom: 8.0,
              enableMultiFingerGestureRace: true,
              minZoom: 2,
              maxZoom: 18.48,
              enableScrollWheel: true,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                onMapMove(position, hasGesture);
              },
              plugins: <MapPlugin>[
                const LocationMarkerPlugin(),
                MarkerClusterPlugin()
              ]),
          layers: [
            TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", // TODO maybe get a maptiler key for better map themes (and dark theme)
                subdomains: ['a', 'b', 'c']),
            LocationMarkerLayerOptions(showAccuracyCircle: true),
            MarkerClusterLayerOptions(
              popupOptions: PopupOptions(
                popupBuilder: (BuildContext context, Marker marker) =>
                    CategoryPopup(marker),
                popupController: _popupLayerController,
                markerRotate: true,
              ),
              builder: (BuildContext context, List<Marker> markers) {
                clusterBtnNumber++;
                return FloatingActionButton(
                  child: Text(markers.length.toString()),
                  onPressed: () {
                    _mapController.fitBounds(getMarkerListMiddle(markers));
                  },
                  heroTag: "clusterBtn$clusterBtnNumber",
                  backgroundColor: Theme.of(context).primaryColor,
                );
              },
              markers: getMarkerList(isTooFarOut),
              maxClusterRadius: 120,
              size: const Size(40, 40),
              fitBoundsOptions: const FitBoundsOptions(
                padding: EdgeInsets.all(50),
              ),
            ),
          ]),
      floatingActionButton: infoMenu(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  AppBar? _appBar() {
    bool isSimpleMode = SettingsManager().isSimpleMode();
    if (isSimpleMode) {
      return AppBar(
        title: const Text("Find nearby categories"),
      );
    }
    return null;
  }

  Widget? infoMenu() {
    if (isTooFarOut) {
      return FloatingActionButton.extended(
        label: const Text("Zoom in to view categories"),
        icon: const Icon(Icons.help),
        heroTag: "helpIcon",
        onPressed: () {
          setState(() {
            _mapController.move(_mapController.center, 12.5);
            isTooFarOut = false;
          });
        },
      );
    }
    return null;
  }

  @override
  initState() {
    super.initState();
    getStartPosition().then((latLng) {
      // Center on position if available
      if (latLng != null) {
        _mapController.move(latLng, 14);
      }
      checkTooFarOut();
    });
  }

  loadNearbyCategories() {
    if (!isTooFarOut) {
      _ncs
          .markerBuilder(
              _ncs.getNearbyCategories(_mapController.center.latitude,
                  _mapController.center.longitude, calculateKmRadius()),
              context)
          .then((value) {
        _markerList = value;
        setState(() {});
      });
    }
  }

  int calculateKmRadius() {
    // Resources:
    // https://wiki.openstreetmap.org/wiki/Zoom_levels
    // https://en.wikipedia.org/wiki/Haversine_formula

    // Zoom lvl | distance from nw / se (measured manually)
    // 12 | 17 km
    // 13 | 9.5 km
    // 15 | 3.4 km
    // 17 | 0.766 km

    if (_mapController.zoom > 17.0) {
      return 1;
    } else if (_mapController.zoom > 15.0) {
      return 3;
    } else if (_mapController.zoom > 13) {
      return 5;
    } else {
      return 8;
    }
  }

  Future<LatLng?> getStartPosition() async {
    // TODO position still has some delay, improve for later
    final LatLng? latLng;
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Position pos = await Geolocator.getCurrentPosition();
      latLng = LatLng(pos.latitude, pos.longitude);
    } else {
      latLng = null;
    }
    return latLng;
  }

  List<Marker> getMarkerList(bool tooFarOut) {
    if (!tooFarOut) {
      return _markerList;
    } else {
      return List.empty();
    }
  }

  LatLngBounds getMarkerListMiddle(List<Marker> markers) {
    double minLat = 1000, maxLat = -1000, minLng = 1000, maxLng = -1000;
    for (Marker marker in markers) {
      if (marker.point.latitude < minLat) {
        minLat = marker.point.latitude;
      }
      if (marker.point.latitude > maxLat) {
        maxLat = marker.point.latitude;
      }
      if (marker.point.longitude < minLng) {
        minLng = marker.point.longitude;
      }
      if (marker.point.longitude > maxLng) {
        maxLng = marker.point.longitude;
      }
    }
    double margin = (maxLng - minLng) / 10;
    return LatLngBounds.fromPoints([
      LatLng(maxLat + margin, minLng - margin),
      LatLng(minLat - margin, maxLng + margin)
    ]);
  }

  onMapMove(MapPosition position, bool hasGesture) {
    // If the onMove doesnt include a (user) gesture, it is the move on user position, in which case we just want to load the markers, as we dont want to trigger a setState during build.
    if (hasGesture) {
      checkTooFarOut();
      if (lastLoadPosition == null) {
        lastLoadPosition = position.center;
        loadNearbyCategories();
      } else {
        // Checks if the map has moved more than 1.5km since tha last categories have been loaded
        // If so, new categories are loaded in
        if (latLngDistance(position.center!, lastLoadPosition!) > 1.5) {
          lastLoadPosition = position.center;
          loadNearbyCategories();
        }
      }
    } else {
      loadNearbyCategories();
      lastLoadPosition = position.center;
    }
  }

  double latLngDistance(LatLng latLng1, LatLng latLng2) {
    var R = 6371; // Radius of the earth in km
    var dLat = deg2rad(latLng2.latitude - latLng1.latitude);
    var dLon = deg2rad(latLng2.longitude - latLng1.longitude);
    var a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(deg2rad(latLng1.latitude)) *
            math.cos(deg2rad(latLng2.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    var c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var d = R * c; // Distance in km
    return d;
  }

  checkTooFarOut() {
    bool valueBefore = isTooFarOut;
    if (_mapController.zoom >= 12) {
      isTooFarOut = false;
    } else {
      isTooFarOut = true;
    }

    if (isTooFarOut != valueBefore) {
      setState(() {});
    }
  }

  double deg2rad(deg) {
    return deg * (math.pi / 180);
  }
}
