import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../commonsUploadFragment.dart';

class ReviewFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8),
        child: SizedBox(
            height: 45,
            child: ElevatedButton(
              onPressed: () {
                InformationCollector().submitData();
              },
              child: Text('Submit to Commons'),
            )));
  }
}