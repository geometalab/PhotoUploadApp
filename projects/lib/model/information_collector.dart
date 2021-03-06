import 'package:image_picker/image_picker.dart';
import 'package:projects/controller/wiki/login_handler.dart';
import 'package:projects/controller/wiki/upload_service.dart';

import 'description.dart';

// Singleton that saves all data from the different upload steps

class InformationCollector {
  static final InformationCollector _informationCollector =
      InformationCollector._internal();

  factory InformationCollector() {
    return _informationCollector;
  }
  InformationCollector._internal();

  List<XFile> images = List.empty(growable: true);
  String? fileName;
  String? fileType;
  List<String> categories = List.empty(growable: true);
  List<Map<String, dynamic>?> categoriesThumb = List.empty(growable: true);
  List<String> depictions = List.empty(growable: true);
  List<Map<String, dynamic>?> depictionsThumb = List.empty(growable: true);
  String? preFillContent; // Is loaded into typeahead categories field
  List<Description> description = List.empty(growable: true);
  bool ownWork = false;
  String? source;
  String? author;
  String? license = 'CC0';
  DateTime date = DateTime.now();

  // Should only be called when all fields are filled correctly
  submitData() async {
    String _author = author!;
    String _source = source!;
    if (ownWork) {
      Userdata? userdata = await LoginHandler().getUserInformationFromFile();
      if (userdata == null) {
        throw ("Could not submit data. Userdata is null.");
      }
      _author = '[[User:${userdata.username}|${userdata.username}]]';
      _source = "Own Work";
    }
    await UploadService().uploadImage(images, fileName!, fileType!, _source,
        description, _author, license!, date, categories, depictions);
  }

  clear() {
    images.clear();
    fileName = null;
    fileType = null;
    description.clear();
    categories.clear();
    categoriesThumb.clear();
    depictions.clear();
    depictionsThumb.clear();
    preFillContent = null;
    ownWork = false;
    source = null;
    author = null;
    license = 'CC0';
    date = DateTime.now();
  }
}
