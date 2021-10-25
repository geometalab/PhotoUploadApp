import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';

class ValueLabelField extends StatelessWidget {
  String? value;
  String? label;
  Icon? icon;

  ValueLabelField(
    this.value,
    this.label,{
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: rowBuilder(),
      )
    );
  }

  List<Widget> rowBuilder () {
    List<Widget> list = new List.empty(growable: true);
    list.add(
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label ?? "", style: smallLabel),
          Text(
            value ?? "",
            style: objectDescription,
          )
        ],
      )
    );
    if(icon != null) {
      list.add(icon!);
    }
    return list;
  }
}
