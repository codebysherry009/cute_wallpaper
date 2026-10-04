import 'package:flutter/foundation.dart';

class ShellProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;

  void setTab(int i) {
    if (i == _index) return;
    _index = i;
    notifyListeners();
  }
}
