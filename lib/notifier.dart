import 'package:flutter/foundation.dart';

///自定义个监听触发类
class EasyXNotifier {
  final List<VoidCallback> _listeners = [];

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    for (final entry in _listeners) {
      if (entry == listener) {
        _listeners.remove(entry);
        return;
      }
    }
  }

  void dispose() {
    _listeners.clear();
  }

  void notify() {
    if (_listeners.isEmpty) return;

    for (final entry in _listeners) {
      try {
        entry.call();
      } catch (e) {
        print(e.toString());
      }
    }
  }
}
