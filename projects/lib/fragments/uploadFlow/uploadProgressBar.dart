import 'package:flutter/material.dart';
import 'package:projects/api/uploadService.dart';

class UploadProgressBar {
  OverlayEntry? _progressOverlayEntry;

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
      // TODO background color feels off
      // TODO smooth ProgressIndicator
      // TODO transition from ProgressIndicator to Checkmark
      // TODO transition checkmark up when text is displayed
      builder: (BuildContext context) => Stack(
            children: <Widget>[
              Container(
                color: Colors.grey.withOpacity(0.7),
                child: Center(
                  // Builder for the progress stream which contains the upload progress as a double
                  child: StreamBuilder<double>(
                    stream: UploadProgressStream().stream,
                    builder:
                        (BuildContext context, AsyncSnapshot<double> snapshot) {
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
                        if (snapshot.data == 1.0) {
                          // If uploading is done
                          return checkMark;
                        } else if (snapshot.data! < 1.0) {
                          // If uploading is in progress
                          child = CircularProgressIndicator(
                            value: snapshot.data,
                          );
                        } else {
                          // If value is > 1.0
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
                              TextButton(
                                  onPressed: () {
                                    hide();
                                  },
                                  child: Text("return to home")),
                            ],
                          );
                        }
                      }
                      return AnimatedSwitcher(
                          duration: Duration(milliseconds: 500),
                          // transitionBuilder: (Widget child, Animation<double> animation) =>
                          //     RotationTransition(turns: animation, child: child),
                          child: child);
                    },
                  ),
                ),
              ),
            ],
          ));
}
