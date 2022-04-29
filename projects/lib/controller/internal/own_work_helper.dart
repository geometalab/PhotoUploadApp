import 'package:projects/model/information_collector.dart';

import '../wiki/login_handler.dart';

class OwnWorkHelper {
  final InformationCollector _collector = InformationCollector();

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
