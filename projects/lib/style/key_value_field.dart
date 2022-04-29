import 'package:flutter/material.dart';
import 'package:projects/style/text_styles.dart';

class ValueLabelField extends StatelessWidget {
  final String? value;
  final String? label;
  final Icon? icon;
  final double? padding;
  final bool replaceEmpty; // Replaces "" with "no value"

  const ValueLabelField(this.value, this.label,
      {this.icon, this.padding, this.replaceEmpty = false, Key? key})
      : super(key: key);

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
    List<Widget> list = List.empty(growable: true);
    list.add(Flexible(
      fit: FlexFit.loose,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label ?? "", style: smallLabel),
          textHandler(value),
        ],
      ),
    ));

    if (icon != null) {
      list.add(icon!);
    }
    return list;
  }

  Text textHandler(String? text) {
    if ((text == null || text == "") && replaceEmpty) {
      return Text(
        "no value",
        style: objectDescription.copyWith(
            color: Colors.grey, fontStyle: FontStyle.italic),
        softWrap: true,
        overflow: TextOverflow.fade,
      );
    } else {
      return Text(
        text ?? "",
        style: objectDescription,
        softWrap: true,
        overflow: TextOverflow.fade,
      );
    }
  }
}
