import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoPopUp extends StatelessWidget {
  final String message;
  InfoPopUp(this.message);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(8),
      verticalOffset: 16,
      showDuration: Duration(minutes: 1),
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(
        Icons.help_outline_outlined,
        color: Theme.of(context).disabledColor,
      ),
    );
  }
}
