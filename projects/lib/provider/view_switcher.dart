import 'package:flutter/cupertino.dart';

class ViewSwitcher extends ChangeNotifier {
  int _viewIndex = 0;

  int get viewIndex {
    return _viewIndex;
  }

  set viewIndex(int viewIndex) {
    _viewIndex = viewIndex;
    notifyListeners();
  }
}
