import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NoConnection {
  Widget screen(BuildContext context) {
    return Scaffold(
      body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.center,
           children: [
             Text("Check your Connection", style: TextStyle(fontSize: 30),),
             Icon(Icons.wifi_off, size: 80,)
           ],
         ),
    ),
    );
  }
}
