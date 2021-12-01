import 'package:flutter/material.dart';
import 'package:projects/view/uploadFlow/selecItems.dart';

class SimpleCategoriesPage extends StatefulWidget {
  @override
  _SimpleCategoriesPageState createState() => _SimpleCategoriesPageState();
}

class _SimpleCategoriesPageState extends State<SimpleCategoriesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SelectItemFragment(0),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Text("Upload to Wikimedia"),
    );
  }
}
