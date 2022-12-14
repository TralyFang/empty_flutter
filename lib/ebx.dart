import 'package:empty_flutter/rxEasy.dart';
import 'package:flutter/material.dart';

typedef WidgetCallback = Widget Function();

class Ebx extends StatefulWidget {
  const Ebx(this.builder, {Key? key}) : super(key: key);

  final WidgetCallback builder;

  @override
  _EbxState createState() => _EbxState();
}

class _EbxState extends State<Ebx> {
  final RxEasy _rxEasy = RxEasy();

  @override
  void initState() {
    super.initState();

    _rxEasy.easyXNotifier.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Widget get notifyChild {
    final observer = RxEasy.proxy;
    RxEasy.proxy = _rxEasy;
    final result = widget.builder();
    if (!_rxEasy.canUpdate) {
      throw 'Widget lacks Rx type variables';
    }
    RxEasy.proxy = observer;
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return notifyChild;
  }

  @override
  void dispose() {
    _rxEasy.easyXNotifier.dispose();

    super.dispose();
  }
}
