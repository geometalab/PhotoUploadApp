import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projects/controller/uploadService.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:provider/provider.dart';

class UploadProgressBar {
  OverlayEntry? _progressOverlayEntry;
  double streamedProgressValue = 0.0;
  bool done = false;
  double incrementValue = 0.0;
  double incrementChangeValue = 0.0;
  ValueNotifier<double> smoothProgressValue = ValueNotifier(0.0);

  void show(BuildContext context) {
    _progressOverlayEntry = _createdProgressEntry(context);
    Overlay.of(context)!.insert(_progressOverlayEntry!);
  }

  void hide() {
    if (_progressOverlayEntry != null) {
      _progressOverlayEntry!.remove();
      _progressOverlayEntry = null;
    }
  }

  OverlayEntry _createdProgressEntry(BuildContext context) => OverlayEntry(
          // TODO smooth fade in of uploadProgressBar
          // TODO smooth ProgressIndicator
          // TODO transition from ProgressIndicator to Checkmark
          // TODO transition checkmark up when text is displayed
          builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            Container(
              color: Colors.black45.withOpacity(0.75),
              child: Center(
                // Builder for the progress stream which contains the upload progress as a double
                child: StreamBuilder<UploadStatus>(
                  stream: UploadProgressStream().stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<UploadStatus> snapshot) {
                    // Child which gets inserted into the AnimatedSwitcher
                    Widget child;
                    // Checkmark which gets displayed on upload finish
                    Icon checkMark = Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 40,
                    );

                    // If stream has not yet broadcast a value
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      child = CircularProgressIndicator();
                    } else {
                      done = snapshot.data!.done;
                      streamedProgressValue = snapshot.data!.progress;
                      if (snapshot.data!.done) {
                        // TODO make better successful upload screen (maybe display upload or smth)
                        // If upload is done
                        child = Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            checkMark,
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                            ),
                            Text("Upload successful",
                                style: Theme.of(context).textTheme.bodyText1),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            ElevatedButton(
                                onPressed: () {
                                  hide();
                                  Provider.of<ViewSwitcher>(context,
                                          listen: false)
                                      .viewIndex = 0;
                                },
                                child: Text(
                                    "Back to home")), // TODO better wording
                          ],
                        );
                      } else if (snapshot.data!.error) {
                        child = Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outlined,
                              color: Theme.of(context).errorColor,
                              size: 40,
                            ),
                            Text(
                                "An error has occured: " +
                                    snapshot.data!.message,
                                style: Theme.of(context).textTheme.bodyText1),
                          ],
                        );
                      } else {
                        // If uploading is in progress
                        child = ValueListenableBuilder(
                          valueListenable: smoothProgressValue,
                          builder: (BuildContext context, double value,
                              Widget? child) {
                            progressManager();
                            if (value >= 0.999) {
                              return checkMark;
                            } else if (value == 0.0) {
                              return CircularProgressIndicator();
                            } else {
                              return CircularProgressIndicator(
                                value: value,
                              );
                            }
                          },
                        );
                      }
                    }
                    return child;
                  },
                ),
              ),
            ),
          ],
        );
      });

  progressManager() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (done) {
        timer.cancel();
      }
      // incrementChangeValue = (streamedProgressValue - smoothProgressValue.value) * 0.01;
      // incrementValue += incrementChangeValue;
      double distance = (streamedProgressValue - smoothProgressValue.value) * 4;
      if(distance > 1.0) {
       distance = 1;
      }
      incrementValue = (Curves.easeInQuart
              .transform(distance)) / 1000;
      smoothProgressValue.value = smoothProgressValue.value + incrementValue;
    });
  }
}
