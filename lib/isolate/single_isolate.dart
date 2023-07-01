
import 'dart:isolate';

typedef ThreadHandler = dynamic Function();
typedef MainHandler = void Function(dynamic);

class IsolateHandler {
  late final ThreadHandler threadHandler;
  late final MainHandler mainHandler;
}

class SingleIsolate {

  static bool openDebug = true;
  static void log(Object? object) {
    if (!openDebug) return;
    print(object);
  }

  /// 最大创建isolate数量: 最好只有一个子线程在跑，多个会形成拥挤。
  static const int _maxIsolate = 1;
  /// 已经创建的数量
  static int _countIsolate = 0;
  /// 等待中的队列
  static final List<Map<SingleIsolate, IsolateHandler>> _waitIsolateList = [];
  /// isolate对象
  late Isolate isolate;
  /// isolate传递的回调
  final Map<SendPort, ThreadHandler> mapThreadHandler = {};

  Future<void> init({required ThreadHandler threadHandler, required MainHandler mainHandler}) async {

    if (_countIsolate >= _maxIsolate) {
      var entity = {this : IsolateHandler()
        ..mainHandler = mainHandler
        ..threadHandler = threadHandler};
      _waitIsolateList.add(entity);
      log('maxIsolate: $_maxIsolate, please await: ${_waitIsolateList.length}');
      return;
    }
    _countIsolate ++;
    log('init isolate...$_countIsolate, max:$_maxIsolate, wait: ${_waitIsolateList.length}');
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((data) {
      if (data is SendPort) {
        SendPort sendPort = data;
        sendPort.send(mapThreadHandler);
        return;
      }
      try {
        // 避免处理异常了，没有销毁资源
        mainHandler(data);
      }catch (e) {
        log('mainHandler error: $e');
      }
      mapThreadHandler.remove(receivePort.sendPort);
      // 一次性的数据处理完成了，需要销毁资源
      receivePort.close();
      dispose();

    });
    mapThreadHandler[receivePort.sendPort] = threadHandler;
    isolate = await Isolate.spawn(_sendPortHandler, receivePort.sendPort);
  }

  void dispose() {
    _countIsolate--;
    isolate.kill();
    if (_waitIsolateList.isNotEmpty) {
      var entity = _waitIsolateList.first.keys.first;
      var handler = _waitIsolateList.first.values.first;
      entity.init(threadHandler: handler.threadHandler, mainHandler: handler.mainHandler);
      _waitIsolateList.removeAt(0);
    }
  }

  /// 这里调用的数据是不共享的, 需要通过port共享数据
  static void _sendPortHandler(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((data) {
      if (data is Map<SendPort, ThreadHandler>) {
        final Map<SendPort, ThreadHandler> mapThreadHandler = data;
        var handlerData;
        try {
          // 避免处理异常了，没有销毁资源
          handlerData = mapThreadHandler[sendPort]?.call();
        }catch (e) {
          log('threadHandler error: $e');
        }
        sendPort.send(handlerData);
        // 任务完成了，就关闭吧
        receivePort.close();
        return;
      }
    });
    sendPort.send(receivePort.sendPort);
  }
}
