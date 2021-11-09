import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Icon(
        Icons.person_outline_rounded,
        color: Color.fromRGBO(229, 229, 229, 1),
      ),
      backgroundColor: Theme.of(context).disabledColor,
    );
  }
}
