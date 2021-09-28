import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuccessfulLogin extends StatelessWidget{
  String userCode;

  SuccessfulLogin(
      this.userCode,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Successfully logged in"),
      ),
      body: Center(
        child: Text(userCode),
      ),
    );
  }

}