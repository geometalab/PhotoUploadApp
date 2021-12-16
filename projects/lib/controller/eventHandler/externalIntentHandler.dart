import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/internal/settingsManager.dart';
import 'package:projects/model/informationCollector.dart';
import 'package:projects/pageContainer.dart';
import 'package:projects/view/simpleUpload/simpleUploadPage.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class ExternalIntentHandler {
  // Gets called when a external intent is received
  processExternalIntent(
      List<SharedMediaFile> sharedMediaList, BuildContext context) {
    if (sharedMediaList.isNotEmpty) {
      // Clear the information collector and add the passed data
      InformationCollector ic = InformationCollector();
      ic.clear();
      ic.image = XFile(sharedMediaList.first.path);

      // Close all routes in case one is open
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Switch to upload menu for simple or normal mode
      if (SettingsManager().isSimpleMode()) {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => SimpleUploadPage(),
          ),
        );
      } else {
        Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 2;
      }
    }
  }
}
