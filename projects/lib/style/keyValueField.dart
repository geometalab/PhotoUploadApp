import 'package:flutter/cupertino.dart';
import 'package:projects/style/textStyles.dart';

class KeyValueField extends StatelessWidget {
  String? initialValue;
  String? label;

  KeyValueField(this.initialValue, this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        children: [
          Text(label ?? "", style: smallLabel),
          Text(
            initialValue ?? "",
            style: objectDescription,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
      padding: EdgeInsets.symmetric(vertical: 4),
    );
  }
}
