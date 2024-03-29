import 'dart:async';
import 'dart:isolate';

typedef SendErrorFunction = Function(Object? data);
typedef MessageHandler = Function(dynamic data);
typedef MainMessageHandler = FutureOr Function(
    dynamic data, SendPort isolateSendPort);
typedef IsolateMessageHandler = FutureOr Function(
    dynamic data, SendPort mainSendPort, SendErrorFunction onSendError);

class Worker {
  late Isolate _isolate;

  late ReceivePort _mainReceivePort;

  late SendPort _isolateSendPort;

  final _completer = Completer();

  bool get isInitialized => _completer.isCompleted;

  Future<void> init(
    MainMessageHandler mainHandler,
    IsolateMessageHandler isolateHandler, {
    Object? initialMessage = const _NoParameterProvided(),
    bool queueMode = false,
    MessageHandler? errorHandler,
    MessageHandler? exitHandler,
  }) async {
    assert(isInitialized == false);
    if (isInitialized) return;

    _mainReceivePort = ReceivePort();
    final errorPort = _initializeAndListen(errorHandler);
    final exitPort = _initializeAndListen(exitHandler);

    _isolate = await Isolate.spawn(
      _isolateInitializer,
      _IsolateInitializerParams(
        _mainReceivePort.sendPort,
        errorPort?.sendPort,
        isolateHandler,
        queueMode,
      ),
      onError: errorPort?.sendPort,
      onExit: exitPort?.sendPort,
    );

    _mainReceivePort.listen((message) async {
      if (message is SendPort) {
        _isolateSendPort = message;
        if (initialMessage is! _NoParameterProvided) {
          // 共享初始化信息给新的isolate
          _isolateSendPort.send(initialMessage);
        }
        _completer.complete();
        return;
      }
      final handlerFuture = mainHandler(message, _isolateSendPort);
      if (queueMode) {
        await handlerFuture;
      }
    }).onDone(() async {
      await Future.delayed(const Duration(seconds: 2));
      errorPort?.close();
      exitPort?.close();
    });

    return await _completer.future;
  }

  void dispose({bool immediate = false}) {
    _mainReceivePort.close();
    _isolate.kill(
      priority: immediate ? Isolate.immediate : Isolate.beforeNextEvent,
    );
  }

  ReceivePort? _initializeAndListen(MessageHandler? handler) {
    if (handler == null) return null;
    return ReceivePort()..listen(handler);
  }

  void sendMessage(Object? message) {
    if (!isInitialized) throw Exception('Worker is not initialized');
    _isolateSendPort.send(message);
  }

  static Future<void> _isolateInitializer(
    _IsolateInitializerParams params,
  ) async {
    var isolateReceiverPort = ReceivePort();

    params.mainSendPort.send(isolateReceiverPort.sendPort);

    await for (var data in isolateReceiverPort) {
      // 回调给使用者来运算，并由使用者决定发送回mainIsolate。
      final handlerFuture = params.isolateHandler(
          data, params.mainSendPort, params.errorSendPort?.send ?? (_) {});
      // params.errorSendPort?.send ?? (_) {} 这个代码就很有意思，直接构建一个方法体
      // 由使用者来触发，错误信息。

      // 如果是队列的话，那就排队解决。
      if (params.queueMode) {
        await handlerFuture;
      }
    }
  }
}

class _IsolateInitializerParams {
  _IsolateInitializerParams(
    this.mainSendPort,
    this.errorSendPort,
    this.isolateHandler,
    this.queueMode,
  );

  final SendPort mainSendPort;
  final SendPort? errorSendPort;
  final IsolateMessageHandler isolateHandler;
  final bool queueMode;
}

class _NoParameterProvided {
  const _NoParameterProvided();
}
