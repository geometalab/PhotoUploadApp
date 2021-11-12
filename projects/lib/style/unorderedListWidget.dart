import 'package:flutter/cupertino.dart';

class UnorderedList extends StatelessWidget {
  UnorderedList(this.texts, this.textStyle);
  final List<String> texts;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(text, textStyle));
      // Add space between items
      widgetList.add(SizedBox(height: 5.0));
    }

    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  UnorderedListItem(this.text, this.textStyle);
  final String text;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("• ", style: textStyle),
        Expanded(
          child: Text(text, style: textStyle),
        ),
      ],
    );
  }
}
