import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ImageSelectorFragment extends StatefulWidget {
  final List<String> images;
  Function(int) callback;

  ImageSelectorFragment(this.images, this.callback);

  @override
  _ImageSelectorFragmentState createState() => _ImageSelectorFragmentState();
}

class _ImageSelectorFragmentState extends State<ImageSelectorFragment>
    with TickerProviderStateMixin {
  // TODO when a image is selected, unselect when new image selected (so only one can be selected at a time)
  // TODO broken in general :)
  int? _selectedImage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select an image"),
      ),
      body: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          children: generateRows(widget.images),
        ),
      ),
      floatingActionButton: floatingActionButton(),
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

  Widget imageContainer(int index, List<String> imageList) {
    if (index < imageList.length) {
      late AnimationController _controller;
      _controller = AnimationController(
        duration: Duration(milliseconds: 120),
        vsync: this,
      );

      final animation = Tween(
        begin: 1.0,
        end: 0.9,
      ).animate(_controller);

      _tapped() {
        if (_selectedImage == index) {
          _selectedImage = null;
          _controller.reverse();
          setState(() {});
        } else {
          _selectedImage = index;
          _controller.forward();
          setState(() {});
        }
      }

      Widget builderChild() {
        if (imageList[index] == "") {
          return Container(
            color: Colors.grey,
            child: Center(
              child: Icon(
                Icons.clear,
                size: 50,
              ),
            ),
          );
        } else {
          return Image.asset(
            imageList[index],
            fit: BoxFit.cover,
          );
        }
      }

      if (_selectedImage == index) {
        _controller.forward();
      } else {
        _controller.reverse();
      }

      return Flexible(
        flex: 1,
        child: GestureDetector(
            onTap: () {
              _tapped();
            },
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: AnimatedBuilder(
                  builder: (BuildContext context, Widget? child) {
                    return Transform.scale(
                      scale: animation.value,
                      child: builderChild(),
                    );
                  },
                  animation: animation,
                ),
              ),
            )),
      );
    } else {
      return Flexible(
        flex: 1,
        child: Container(),
      );
    }
  }

  Widget? floatingActionButton() {
    if (_selectedImage != null) {
      return FloatingActionButton(
        onPressed: () {
          widget.callback(_selectedImage!);
          Navigator.pop(context);
        },
        child: Icon(Icons.done),
      );
    } else {
      return null;
    }
  }
}
