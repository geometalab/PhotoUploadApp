import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageSelectorFragment extends StatefulWidget {
  final List<String> images;

  ImageSelectorFragment(this.images);

  @override
  _ImageSelectorFragmentState createState() => _ImageSelectorFragmentState();
}

class _ImageSelectorFragmentState extends State<ImageSelectorFragment> {
  int? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select an image"),
      ),
      body: Column(
        children: generateRows(widget.images),
      ),
    );
  }

  List<Row> generateRows(List<String> imageList) {
    List<Row> rowList = List.empty(growable: true);
    for (int i = 0; i < imageList.length; i = i + 3) {
      rowList.add(Row(
        children: [
            imageContainer(i, imageList),
            imageContainer(i + 1, imageList),
            imageContainer(i + 2, imageList),
        ],
      ));
    }
    return rowList;
  }

  Widget imageContainer (int index, List<String> imageList) {
    if (index < imageList.length) {
      return Flexible(
        flex: 1,
        child: GestureDetector(
            child: AspectRatio(
              aspectRatio: 1/1,
              child: Image.asset(imageList[index], fit: BoxFit.cover,),
            )
        ),
      );
    } else {
      return Flexible(
        flex: 1,
        child: Container(),
      );
    }

  }
}
