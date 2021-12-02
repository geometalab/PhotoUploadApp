import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/view/userFragment.dart';

class SimpleUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Wikimedia Account"),
        ),
        body: UserFragment());
  }
}
