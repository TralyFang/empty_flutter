import 'package:empty_flutter/easy.dart';
import 'package:empty_flutter/easyBindWidget.dart';
import 'package:empty_flutter/ebx.dart';
import 'package:empty_flutter/rx_ext.dart';
import 'package:flutter/material.dart';

class EasyXEbxCounterLogic {
  RxInt count = 0.ebs;

  ///自增
  void increase() => ++count;
}

class EasyXEbxCounterPage extends StatelessWidget {
  final EasyXEbxCounterLogic logic = Easy.put(EasyXEbxCounterLogic());

  @override
  Widget build(BuildContext context) {
    return EasyBindWidget(
      bind: logic,
      child: Scaffold(
        appBar: AppBar(title: const Text('EasyX-自定义Ebx刷新机制')),
        body: Center(
          child: Ebx(() {
            return Text(
              '点击了 ${logic.count.value} 次',
              style: TextStyle(fontSize: 30.0),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => logic.increase(),
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
