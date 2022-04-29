import 'package:flutter/material.dart';

class InfoPopUp extends StatelessWidget {
  final String message;
  const InfoPopUp(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      verticalOffset: 16,
      showDuration: const Duration(minutes: 1),
      triggerMode: TooltipTriggerMode.tap,
      child: Icon(
        Icons.help_outline_outlined,
        color: Theme.of(context).disabledColor,
      ),
    );
  }
}
