import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projects/style/textStyles.dart';

class NoConnection extends StatefulWidget {
  @override
  _NoConnectionState createState() => _NoConnectionState();
}

class _NoConnectionState extends State<NoConnection> {
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: searchWait,
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.hasData){
              return Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Connection lost", style: articleTitle,),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                    Icon(
                      Icons.signal_wifi_connected_no_internet_4,
                      size: 60,
                      color: Theme.of(context).disabledColor,
                    ),
                    Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                    Text(
                      "Connection with Wikimedia could not be established. "
                      "Check your internet connection or try again later.",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            } else {
              return CircularProgressIndicator.adaptive();
            }
          },
        )
      ),
    );
  }

  final Future<String> searchWait = Future<String>.delayed(
    const Duration(milliseconds: 1200), () => 'done',
  );
}
