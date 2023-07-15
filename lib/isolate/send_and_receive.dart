
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

const filename = 'json_01.json';

Future<void> main() async {
  final jsonData = await _spawnAndReceive(filename);
  print('Received JSON with ${jsonData.length} keys');
}

/// 展示了如何从主 isolate 发送消息至生成的 isolate。
/// 源码 https://github.com/dart-lang/samples/blob/main/isolates/bin/send_and_receive.dart
/// 文档 https://dart.cn/guides/language/concurrency#how-isolates-work

Future<Map<String, dynamic>> _spawnAndReceive(String fileName) async {
  final p = ReceivePort();
  await Isolate.spawn(_readAndParseJson, [p.sendPort, fileName]);
  // 接收运算结果
  return (await p.first) as Map<String, dynamic>;
}

void _readAndParseJson(List<dynamic> args) async {
  SendPort responsePort = args[0];
  String fileName = args[1];

  final fileData = await File(fileName).readAsString();
  final result = jsonDecode(fileData);
  // 结束运算，顺便把结果返回去
  Isolate.exit(responsePort, result);
}