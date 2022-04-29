import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import 'package:projects/style/text_styles.dart' as text_styles;
import 'package:projects/style/themes.dart';
import 'package:provider/provider.dart';

import '../../page_container.dart';

class IntroductionView extends StatefulWidget {
  const IntroductionView({Key? key}) : super(key: key);

  @override
  _IntroductionViewState createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  SettingsManager settingsManager = SettingsManager();
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
          slideIconWidget: const Icon(Icons.arrow_back_ios),
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
    return _sampleContainer(
        color: Theme.of(context).colorScheme.background,
        showSkipButton: true,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "    A quick introduction to ",
                style: text_styles.introSmallText,
              ),
              Text(
                "Commons",
                style: text_styles.introBigText,
              ),
              Text(
                "   Uploader",
                style: text_styles.introBigText,
              ),
            ],
          ),
          Image.asset(
            "assets/icon/icon.png",
            height: 300,
          )
        ]));
  }

  Widget _wikiCommons(BuildContext context) {
    return _sampleContainer(
        color: Theme.of(context).colorScheme.background,
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(padding: EdgeInsets.only(bottom: 24)),
                Text("What is Commons?", style: text_styles.introBigText),
                Text(
                  "Wikimedia Commons (or simply Commons) is a media repository of free-use images, sounds and other media.",
                  style: text_styles.introSmallText,
                  textAlign: TextAlign.end,
                ),
                Text(
                    "It is a project of the Wikimedia Foundation. As of March 2021, the repository contains over 70 million free-to-use media files, managed and editable by registered volunteers.",
                    style: text_styles.introSmallText),
                Text(
                  "And with this app, you can become a volunteer yourself",
                  style: text_styles.introSmallText,
                  textAlign: TextAlign.end,
                ),
                const Padding(padding: EdgeInsets.only(bottom: 24)),
              ],
            )));
  }

  Widget _uploadAnything(BuildContext context) {
    return _sampleContainer(
        color: Theme.of(context).colorScheme.secondary,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Upload your images",
                style: text_styles.introBigText
                    .copyWith(color: Theme.of(context).colorScheme.onSecondary),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.grid_view,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text("Select images directly from your gallery",
                        style: text_styles.introSmallText.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.photo_camera,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text("or capture a new one",
                        style: text_styles.introSmallText.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary)),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.place,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  Flexible(
                    child: Text("Find nearby Points of Interest",
                        style: text_styles.introSmallText.copyWith(
                            color: Theme.of(context).colorScheme.onSecondary)),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _simpleMode(BuildContext context) {
    return _sampleContainer(
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Simple Mode",
                style: text_styles.introBigText.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 64)),
            Text(
              "If you are inexperienced in uploading to Commons, you might be looking for a more straight-forward upload process.",
              style: text_styles.introSmallText
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
            ),
            Text(
              "With simple mode enabled, only the most important info and fields are shown, while potentially distracting features are removed.",
              style: text_styles.introSmallText
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
              textAlign: TextAlign.end,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Theme.of(context).primaryColor,
                  ),
                  child: Transform.scale(
                    scale: 1.4,
                    child: Checkbox(
                      value: settingsManager.isSimpleMode(),
                      onChanged: (bool? value) {
                        setState(() {
                          settingsManager.setSimpleMode(value ?? false);
                          Provider.of<ViewSwitcher>(context, listen: false)
                              .viewIndex = 0; // Refresh screen behind this view
                        });
                      },
                      checkColor: Theme.of(context).colorScheme.onSecondary,
                      activeColor: Theme.of(context).colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
                Text("Use simple mode",
                    style: text_styles.introSmallText.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                        height: 1.3)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _letsStart(BuildContext context) {
    return _sampleContainer(
        color: CustomColors.wikimediaThemeBlue,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Are you ready?",
                style: text_styles.introBigText.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              Text(
                "To start, browse nearby categories or sign in to your Wikimedia account.",
                style: text_styles.introSmallText.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const Padding(padding: EdgeInsets.all(16)),
              SizedBox(
                width: 140,
                height: 48,
                child: OutlinedButton(
                  child: Text(
                    "Got it",
                    style: text_styles.introSmallText
                        .copyWith(color: Colors.white),
                  ),
                  onPressed: () {
                    closeView();
                  },
                  style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _sampleContainer(
      {required Color color,
      required Widget child,
      bool showSkipButton = false}) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 100,
            child: Container(
              color: color,
              child: child,
            ),
          ),
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
          if (showSkipButton)
            Positioned(
              bottom: 8,
              left: 8,
              child: TextButton(
                child: const Text("Skip introduction",
                    style: TextStyle(color: Colors.white)),
                onPressed: () {
                  closeView();
                },
              ),
            )
        ],
      ),
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
    return DotsIndicator(
      position: position,
      dotsCount: max,
      decorator: DotsDecorator(
        size: const Size.fromRadius(4),
        activeSize: const Size.fromRadius(8),
        color: Colors.white,
        activeColor: Theme.of(context).colorScheme.secondary,
      ),
      onTap: (double pos) {
        setState(() {
          // Set if swipe is forward or backward and animate to tapped page
          forwardSwipe = pos >= liquidController.currentPage;
          liquidController.animateToPage(page: pos.toInt());
        });
      },
    );
  }

  slideCallback(double pos) {
    // Only call if build is completed and position is not initializing to 0.0
    if (mounted) {
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
    if (mounted) {
      setState(() {
        slidePosition = 0.0;
        pagePosition = pos;
      });
    }
  }

  closeView() {
    SettingsManager().setFirstTime(false);
    Future.delayed(const Duration(milliseconds: 100));
    Navigator.pop(context);
  }
}
