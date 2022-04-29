import 'package:flutter/material.dart';
import 'package:projects/style/text_styles.dart';

class NoConnection extends StatefulWidget {
  const NoConnection({Key? key}) : super(key: key);

  @override
  _NoConnectionState createState() => _NoConnectionState();
}

class _NoConnectionState extends State<NoConnection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FutureBuilder(
        future: searchWait,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Connection lost",
                    style: articleTitle,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                  Icon(
                    Icons.signal_wifi_connected_no_internet_4,
                    size: 60,
                    color: Theme.of(context).disabledColor,
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 4)),
                  const Text(
                    "Connection with Wikimedia could not be established. "
                    "Check your internet connection or try again later.",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator.adaptive();
          }
        },
      )),
    );
  }

  final Future<String> searchWait = Future<String>.delayed(
    const Duration(milliseconds: 1200),
    () => 'done',
  );
}
