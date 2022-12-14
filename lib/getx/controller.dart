import 'package:empty_flutter/notifier.dart';

class EasyXController {
  EasyXNotifier xNotifier = EasyXNotifier();

  ///刷新控件
  void update() {
    xNotifier.notify();
  }
}
