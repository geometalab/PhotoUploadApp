import 'package:flutter/material.dart';
import 'package:projects/api/uploadService.dart';
import 'package:projects/style/textStyles.dart' as customStyles;

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
      builder: (BuildContext context) => Stack(
            children: <Widget>[
              Container(
                color: Colors.grey.withOpacity(0.5),
              ),
              Center(
                child: StreamBuilder<double>(
                  stream: UploadProgressStream().stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<double> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check,
                            color: Colors.green,
                            size: 40,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          Text("Upload successful",
                              style: Theme.of(context).textTheme.bodyText1),
                          TextButton(
                              onPressed: () => hide(),
                              child: Text("back to Homepage")),
                        ],
                      );
                    } else {
                      if (snapshot.data == 1.0) {
                        return Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 40,
                        );
                      } else {
                        return CircularProgressIndicator(
                          value: snapshot.data,
                        );
                      }
                    }
                  },
                ),
              )
            ],
          ));
}
