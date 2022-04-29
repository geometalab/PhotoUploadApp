import 'package:flutter/material.dart';
import 'package:projects/view/user_fragment.dart';

class SimpleUsersPage extends StatelessWidget {
  const SimpleUsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Wikimedia Account"),
        ),
        body: const UserFragment());
  }
}
