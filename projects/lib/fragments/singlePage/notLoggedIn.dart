import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';

class NotLoggedIn extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.person_add_disabled_outlined,
            size: 60,
            color: Theme.of(context).disabledColor,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Text(
            "Not logged in",
            style: articleTitle,
          ),
          Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          Text(
            "Log into your wikimedia account to begin uploading.",
          ),
        ],
      ),
    );
  }

}