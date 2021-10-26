import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';

class ValueLabelField extends StatelessWidget {
  final String? value;
  final String? label;
  final Icon? icon;
  final double? padding;

  ValueLabelField(
    this.value,
    this.label, {
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: padding ?? 4, horizontal: 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: rowBuilder(),
      ),
    );
  }

  List<Widget> rowBuilder() {
    List<Widget> list = new List.empty(growable: true);
    list.add(Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label ?? "", style: smallLabel),
          Text(
            value ?? "",
            style: objectDescription,
            softWrap: true,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    ));

    if (icon != null) {
      list.add(icon!);
    }
    return list;
  }
}
