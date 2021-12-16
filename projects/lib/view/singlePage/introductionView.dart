import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:projects/controller/internal/settingsManager.dart';

class IntroductionView extends StatefulWidget {
  @override
  _IntroductionViewState createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  LiquidController liquidController = LiquidController();
  int pagePosition = 0;
  double slidePosition = 0.0;
  bool forwardSwipe = true;

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
      body: Listener(
        // Listener to check if swipe is forward or backward. This is used to animate the dotsIndicator() correctly
        onPointerMove: (moveEvent) {
          if (moveEvent.delta.dx > 8) {
            forwardSwipe = false;
          } else if (moveEvent.delta.dx < -8) {
            forwardSwipe = true;
          }
        },
        child: LiquidSwipe(
          pages: pages,
          liquidController: liquidController,
          slideIconWidget: Icon(Icons.arrow_back_ios),
          onPageChangeCallback: (int page) {
            positionCallback(page);
          },
          slidePercentCallback: (double position, _) {
            slideCallback(position);
          },
        ),
      ),
      floatingActionButton: dotsIndicator(pages.length),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _welcome(BuildContext context) {
    return _sampleContainer(color: Colors.white, children: [
      Text(
        "welcome",
        style: TextStyle(color: Colors.black87),
      )
    ]);
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
    return Stack(
      children: [
        Container(
            height: double.infinity,
            width: double.infinity,
            color: color,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: children,
            )),
        Positioned(
          bottom: 0,
          left: 0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 130,
            child: ClipPath(
              clipper: WaveClipperOne(flip: true, reverse: true),
              child: Container(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget dotsIndicator(int max) {
    double position = pagePosition + (slidePosition / 100);
    if (position > max.toDouble()) {
      position = max.toDouble();
    }
    if (position < 0) {
      position = 0;
    }
    return Container(
        child: DotsIndicator(
      position: position,
      dotsCount: max,
      decorator: DotsDecorator(
        size: Size.fromRadius(4),
        activeSize: Size.fromRadius(8),
        color: Colors.white,
        activeColor: Theme.of(context).colorScheme.secondary,
      ),
      onTap: (double pos) {
        setState(() {
          positionCallback(pos.toInt());
          liquidController.animateToPage(page: pagePosition);
        });
      },
    ));
  }

  slideCallback(double pos) {
    // Only call if build is completed and position is not initializing to 0.0
    if (this.mounted) {
      if (pos > 0.01) {
        setState(() {
          if (!forwardSwipe) {
            pos = pos * -1;
          }
          slidePosition = pos;
        });
      }
    }
  }

  positionCallback(int pos) {
    if (this.mounted) {
      setState(() {
        slidePosition = 0.0;
        pagePosition = pos;
      });
    }
  }
}
