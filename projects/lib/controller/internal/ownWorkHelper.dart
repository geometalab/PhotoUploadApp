import 'package:projects/model/informationCollector.dart';

import '../wiki/loginHandler.dart';

class OwnWorkHelper {
  InformationCollector _collector = InformationCollector();

  Future<void> setOwnWork() async {
    _collector.source = "Own Work";
    var value = await LoginHandler().getUserInformationFromFile();
    _collector.author = value!.username;
    _collector.ownWork = true;
  }

  removeOwnWork() {
    _collector.source = "";
    _collector.author = "";
    _collector.ownWork = false;
  }
}
