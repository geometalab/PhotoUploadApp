import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';



class ButtonNavigationBar extends StatelessWidget {
  ButtonNavigationBar({required this.children, this.padding = EdgeInsets.zero, this.spaceBetweenItems = 1.5, this.borderRadius = const BorderRadius.all(Radius.circular(16))});

  final List<ButtonNavigationItem> children;
  final EdgeInsets padding;
  final double spaceBetweenItems;
  final BorderRadius borderRadius;



  Widget childBuilder (Icon? icon, String? label) {
    if(icon != null && label != null){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          Text(label)
        ],
      );
    } else if (icon != null){
      return icon;
    } else if (label != null){
      return Text(label);
    } else {
      return SizedBox.shrink();
    }
  }

  BorderRadius borderBuilder (int position) {
    if(position == 0){
      return BorderRadius.only(bottomLeft: borderRadius.bottomLeft, topLeft: borderRadius.topLeft);
    }else if(position == children.length - 1){
      return BorderRadius.only(bottomRight: borderRadius.bottomRight, topRight: borderRadius.topRight);
    }else{
      return BorderRadius.zero;
    }
  }

  List<Widget> rowChildren (List<ButtonNavigationItem> children) {
    List<Widget> rowChildren = new List.empty(growable: true);
    for(int i = 0; i < children.length; i++) {
      rowChildren.add(rowChild(children[i], i));
      if(i != children.length - 1) {
        rowChildren.add(Padding(padding: EdgeInsets.symmetric(horizontal: spaceBetweenItems)));
      }
    }
    return rowChildren;
  }

  SizedBox rowChild (ButtonNavigationItem item, int position) {
    return SizedBox(
      child: ElevatedButton(
        onPressed: item.onPressed,
        child: childBuilder(Icon(item.icon), item.label),
        style: ElevatedButton.styleFrom(
          primary: item.color,
          shape: new RoundedRectangleBorder(
              borderRadius: borderBuilder(position)
          ),
        ),
      ),
      height: item.height,
      width: item.width,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: rowChildren(children),
      ),
    );
  }

}

class ButtonNavigationItem {
  ButtonNavigationItem({this.label, this.icon, this.color, this.height = 48, this.width = 72, required this.onPressed, });

  final String? label;
  final IconData? icon;
  final Color? color;
  final double height;
  final double width;
  final VoidCallback onPressed;
}
