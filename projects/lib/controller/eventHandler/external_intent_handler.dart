import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/internal/settings_manager.dart';
import 'package:projects/model/information_collector.dart';
import 'package:projects/view/simpleUpload/simple_upload_page.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../provider/view_switcher.dart';

class ExternalIntentHandler {
  // Gets called when a external intent is received
  processExternalIntent(
      List<SharedMediaFile> sharedMediaList, BuildContext context) {
    if (sharedMediaList.isNotEmpty) {
      // Clear the information collector and add the passed data
      InformationCollector ic = InformationCollector();
      ic.clear();
      ic.images = sharedMediaList.map((e) => XFile(e.path)).toList();

      // Close all routes in case one is open
      while (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // Switch to upload menu for simple or normal mode
      if (SettingsManager().isSimpleMode()) {
        Navigator.push<void>(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => const SimpleUploadPage(),
          ),
        );
      } else {
        Provider.of<ViewSwitcher>(context, listen: false).viewIndex = 2;
      }
    }
  }
}
