import 'package:flutter/material.dart';
import 'package:projects/style/text_styles.dart';

class NotLoggedIn extends StatelessWidget {
  const NotLoggedIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO route to login screen for both simple and normal mode
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
          const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          const Text(
            "Not logged in",
            style: articleTitle,
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
          const Text(
            "Log into your wikimedia account to begin uploading.",
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
