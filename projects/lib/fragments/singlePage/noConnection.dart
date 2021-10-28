import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';

class NoConnection extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.signal_wifi_connected_no_internet_4,
                size: 60,
                color: Theme.of(context).disabledColor,
              ),
              Text(
                "Connection with Wikimedia could not be established.",
                style: objectDescription.copyWith(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
