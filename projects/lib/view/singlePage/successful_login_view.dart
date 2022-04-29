import 'package:flutter/material.dart';
import 'package:projects/controller/wiki/login_handler.dart';

class SuccessfulLogin extends StatelessWidget {
  final String userCode;

  const SuccessfulLogin(this.userCode, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoginHandler().getTokens(userCode);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Successfully logged in"),
      ),
      body: Center(
        child: Text(userCode),
      ),
    );
  }
}
