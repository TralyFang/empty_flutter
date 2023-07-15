
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:async/async.dart';

const filenames = [
  'json_01.json',
  'json_02.json',
  'json_03.json',
];

void main() async {
  await for (final jsonData in _sendAndReceive(filenames)) {
    print('Received JSON with ${jsonData.length} keys');
  }
}

/// 展示了如何生成一个长期运行、且多次发送和接收消息的 isolate。
/// 源码 https://github.com/dart-lang/samples/blob/main/isolates/bin/long_running_isolate.dart
/// 文档 https://dart.cn/guides/language/concurrency#how-isolates-work
Stream<Map<String, dynamic>> _sendAndReceive(List<String> filenames) async* {
  final p = ReceivePort();
  await Isolate.spawn(_readAndParseJsonService, p.sendPort);

  final events = StreamQueue<dynamic>(p);

  SendPort sendPort = await events.next;

  for (var filename in filenames) {
    // 依次将参数发送给新的isolate 然后接受运算结果，通过stream发送给主isolate
    sendPort.send(filename);
    Map<String, dynamic> message = await events.next;
    yield message;
  }
  // 通知新的isolate任务完成了
  sendPort.send(null);

  await events.cancel();
}

Future<void> _readAndParseJsonService(SendPort p) async {
  print('Spawned isolate started.');

  final commandPort = ReceivePort();
  // 将自己的端口发送给主isolate，用来通信
  p.send(commandPort.sendPort);
  await for (final message in commandPort) {
    // 接收从主isolate发送过来的数据，计算后再发送出去
    if (message is String) {
      final contents = await File(message).readAsString();
      p.send(jsonDecode(contents));
    } else if (message == null) {
      break;
    }
  }
  print('Spawned isolate finished.');
  Isolate.exit();
}