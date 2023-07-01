import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';

import 'single_isolate.dart';

void main() {

}

class TTScheduleIsolate {
  static Future<void> test() async {

    var now = DateTime.now().millisecondsSinceEpoch;
    print('now: $now');
    
    var handler = () {
      var threadNow = DateTime.now().millisecondsSinceEpoch;
      print('子线程执行task: $now, ${threadNow - now}');
      // var ii = ['1'][2];
      var index = 0;
      var sum = 0;
      for (var i = 0; i < 99999999; i++) {
        sum = index * index % 2;
        index ++;
      }
      return 'task 完成 $index, sum:$sum, ${DateTime.now().millisecondsSinceEpoch - threadNow}';
    };
    
    // print(handler());
    // return;
    

    // 这里的await仅仅是创建isolate的时间
    SingleIsolate().init(threadHandler: handler, mainHandler: (data) {
      var newNow = DateTime.now().millisecondsSinceEpoch;
      // 这里才是处理isolate回调的时间
      print('main $data, duration:${newNow - now}');
    }).then((value) {
      var newNow = DateTime.now().millisecondsSinceEpoch;
      print('isolate end duration:${newNow - now}');
    });
    var newNow = DateTime.now().millisecondsSinceEpoch;
    print('wait end duration:${newNow - now}');
  }
}

class TTIsolate {
  /// 新线程执行新的任务 并监听
  late Isolate isolate;
  late Isolate isolate2;

  void createTask() async {

    var model = await compute(jsonDecode, 'jsonString');

    /// isolate： 构建一个 isolate需要一个 ReceivePort，而ReceivePort中又带有sendPort
    /// sendPort.send 可以回调到ReceivePort.listen中来。
    /// 也就是子isolate 也是可以通过sendPort接受主isolate传递过来的信息。

    ReceivePort receivePort = ReceivePort();
    isolate = await Isolate.spawn(sendP1, receivePort.sendPort);
    receivePort.listen((data) {
      print(data);
      if (data is List) {
        SendPort subSencPort = data[1];
        String msg = data[0];
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