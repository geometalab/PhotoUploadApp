import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: const Icon(
        Icons.person_outline_rounded,
        color: Color.fromRGBO(229, 229, 229, 1),
      ),
      backgroundColor: Theme.of(context).disabledColor,
    );
  }
}
