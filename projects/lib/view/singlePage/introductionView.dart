import 'package:flutter/material.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:projects/controller/internal/settingsManager.dart';

class IntroductionView extends StatefulWidget {
  @override
  _IntroductionViewState createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  @override
  Widget build(BuildContext context) {
    final pages = [
      _welcome(context),
      _wikiCommons(context),
      _uploadAnything(context),
      _simpleMode(context),
      _letsStart(context)
    ];

    return Scaffold(
      body: LiquidSwipe(
        pages: pages,
        slideIconWidget: Icon(Icons.arrow_back_ios),
      ),
    );
  }

  Widget _welcome(BuildContext context) {
    return _sampleContainer(color: Colors.brown, children: [Text("welcome")]);
  }

  Widget _wikiCommons(BuildContext context) {
    return _sampleContainer(
        color: Colors.redAccent, children: [Text("wikimedia commons is...")]);
  }

  Widget _uploadAnything(BuildContext context) {
    return _sampleContainer(
        color: Colors.lightBlueAccent, children: [Text("upload anything")]);
  }

  Widget _simpleMode(BuildContext context) {
    return _sampleContainer(
        color: Colors.greenAccent, children: [Text("simple mode?")]);
  }

  Widget _letsStart(BuildContext context) {
    return _sampleContainer(color: Colors.blueGrey, children: [
      ElevatedButton(
        child: Text("lets start"),
        onPressed: () {
          SettingsManager().setFirstTime(false);
          Future.delayed(Duration(milliseconds: 100));
          Navigator.pop(context);
          setState(() {});
        },
      ),
    ]);
  }

  Widget _sampleContainer(
      {required Color color, required List<Widget> children}) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        color: color,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: children,
        ));
  }
}
