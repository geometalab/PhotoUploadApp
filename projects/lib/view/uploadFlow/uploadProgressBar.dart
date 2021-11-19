import 'package:flutter/material.dart';
import 'package:projects/controller/uploadService.dart';
import 'package:projects/pages/menuDrawer.dart';
import 'package:provider/provider.dart';

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
                        if (snapshot.data!.progress == 1.0 &&
                            !snapshot.data!.done) {
                          // If uploading is done
                          return checkMark;
                        } else if (snapshot.data!.done) {
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
                          child = CircularProgressIndicator(
                            value: snapshot.data!.progress,
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
