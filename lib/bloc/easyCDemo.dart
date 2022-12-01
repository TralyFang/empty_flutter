import 'package:empty_flutter/bloc/easyC.dart';
import 'package:empty_flutter/bloc/easyCBuilder.dart';
import 'package:empty_flutter/bloc/easyCProvider.dart';
import 'package:flutter/material.dart';

class CounterEasyCPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EasyCProvider(
      create: (BuildContext context) => CounterEasyC(),
      child: Builder(builder: (context) => _buildPage(context)),
    );
  }

  Widget _buildPage(BuildContext context) {
    final easyC = EasyCProvider.of<CounterEasyC>(context);

    return Scaffold(
      appBar: AppBar(title: Text('自定义状态管理框架-EasyC范例')),
      body: Center(
        child: EasyCBuilder<CounterEasyC, CounterEasyCState>(
          builder: (context, state) {
            return Text(
              '点击了 ${easyC.state.count} 次',
              style: TextStyle(fontSize: 30.0),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => easyC.increment(),
        child: Icon(Icons.add),
      ),
    );
  }
}


class CounterEasyC extends EasyC<CounterEasyCState> {
  CounterEasyC() : super(CounterEasyCState().init());

  ///自增
  void increment() => emit(state.clone()..count = ++state.count);
}


class CounterEasyCState {
  late int count;

  CounterEasyCState init() {
    return CounterEasyCState()..count = 0;
  }

  CounterEasyCState clone() {
    return CounterEasyCState()..count = count;
  }
}