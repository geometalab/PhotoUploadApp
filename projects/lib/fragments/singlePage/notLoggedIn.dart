import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotLoggedIn extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Not logged in",
            style: TextStyle(fontSize: 30),
          ),
          Text(
            "Log into your wikimedia account to begin uploading."
          ),
          Icon(
            Icons.person_add_disabled_outlined,
            size: 60,
          )
        ],
      ),
    );
  }

}