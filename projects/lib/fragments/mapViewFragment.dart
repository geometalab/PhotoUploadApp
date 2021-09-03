import 'package:flutter/material.dart';
import 'package:projects/api/nearbyCategoriesService.dart';

class MapFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    var lists = NearbyCategoriesService().getNearbyCategories(47.2, 8.8, 1);

    // TODO: implement map
    return new Center(
      child: new Text("Nearby Entrys"),
    );
  }

}