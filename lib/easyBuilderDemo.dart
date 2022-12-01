import 'package:empty_flutter/controller.dart';
import 'package:empty_flutter/easy.dart';
import 'package:empty_flutter/easyBuilder.dart';
import 'package:flutter/material.dart';

class EasyXCounterLogic extends EasyXController {
  var count = 0;

  void increase() {
    ++count;
    update();
  }
}

class EasyXCounterPage extends StatelessWidget {
  final EasyXCounterLogic logic = Easy.put(EasyXCounterLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EasyX-自定义EasyBuilder刷新机制')),
      body: Center(
        child: EasyBuilder<EasyXCounterLogic>(builder: (logic) {
          return Text(
            '点击了 ${logic.count} 次',
            style: TextStyle(fontSize: 30.0),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => logic.increase(),
        child: Icon(Icons.add),
      ),
    );
  }
}
