import 'dart:isolate';

import 'package:flutter_isolate/flutter_isolate.dart';

import 'handled_isolate_messenger.dart';

class HandledIsolate<T> {
  final HandledIsolateMessenger _messenger;
  late final FlutterIsolate _isolate;
  final String _name;

  FlutterIsolate get isolate => _isolate;

  Capability? get pauseCapability => isolate.pauseCapability;

  String get name => _name;

  HandledIsolateMessenger get messenger => _messenger;

  HandledIsolate({
    required String name,
    required void Function(Map<String, dynamic>) function,
    void Function()? onInitialized,
    bool paused = false,
    bool? errorsAreFatal,
    SendPort? onExit,
    SendPort? onError,
    String? debugName,
  })  : _messenger = HandledIsolateMessenger(onInitialized: onInitialized),
        _name = name {
    _init(
      function,
      paused: paused,
      errorsAreFatal: errorsAreFatal,
      onExit: onExit,
      onError: onError,
      debugName: debugName,
    );
  }

  static HandledIsolateMessenger initialize(Map<String, dynamic> context) {
    final messenger = context['messenger'] as SendPort;
    final msg = HandledIsolateMessenger(remotePort: messenger);
    messenger.send(msg.inPort.sendPort);
    return msg;
  }

  void _init(
    Function(Map<String, dynamic>) function, {
    bool paused = false,
    bool? errorsAreFatal,
    SendPort? onExit,
    SendPort? onError,
    String? debugName,
  }) async {
    final message = {
      'messenger': messenger.outPort,
      'name': name,
    };
    _isolate = await FlutterIsolate.spawn(function, message);
  }

  void pause([Capability? resumeCapability]) {
    isolate.pause();
  }

  void resume([Capability? resumeCapability]) {
    isolate.resume();
  }

  void dispose({int priority = Isolate.beforeNextEvent}) {
    _isolate.kill(priority: priority);

    _messenger.dispose();
  }
}
