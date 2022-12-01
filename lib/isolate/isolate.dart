import 'dart:isolate';

import 'package:flutter/foundation.dart';

void main() {

}


class TTIsolate {
  /// 新线程执行新的任务 并监听
  late Isolate isolate;
  late Isolate isolate2;

  void createTask() async {
    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(sendP1, receivePort.sendPort);
    receivePort.listen((data) {
      print(data);
      if (data is List) {
        SendPort subSencPort = (data as List)[1];
        String msg = (data as List)[0];
        print('$msg 在主线程收到');
        if (msg == 'close') {
          receivePort.close();
        } else if (msg == 'task') {
          taskMain();
        }
        subSencPort.send(['主线程发出']);
      }
    });
  }

  void sendP1(SendPort sendPort) async {
    ReceivePort receivePort = new ReceivePort();
    receivePort.listen((data) async {
      print(data);
      if (data is List) {
        String msg = (data as List)[0];
        print('$msg 在子线程收到');
        if (msg == 'close') {
          receivePort.close();
        } else if (msg == 'task') {
          var m = await task();
          sendPort.send(['$m', receivePort.sendPort]);
        }
      }
    });
    sendPort.send(['子线程线程发出', receivePort.sendPort]);
  }

  Future<String> task() async {
    print('子线程执行task');
    for (var i = 0; i < 99999999; i++) {}
    return 'task 完成';
  }

  void taskMain() {
    print('主线程执行task');

    // compute();
    // compute((){}, null);
  }

  /*
  *
[子线程线程发出, SendPort]
子线程线程发出 在主线程收到
[主线程发出]
主线程发出 在子线程收到
  *
  * */
}