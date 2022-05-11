import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar(this.iconData, {Key? key}) : super(key: key);
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Icon(
        iconData,
        color: const Color.fromRGBO(229, 229, 229, 1),
      ),
      backgroundColor: Theme.of(context).disabledColor,
    );
  }
}
