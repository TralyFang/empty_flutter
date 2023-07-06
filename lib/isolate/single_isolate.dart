
import 'dart:async';
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

  static Future<T> compute<T>(ThreadHandler threadHandler) {
    Completer<T> completer = Completer<T>();
    SingleIsolate().init(threadHandler: threadHandler, mainHandler: (data) {
      completer.complete(data);
    });
    return completer.future;
  }

  /// 最大创建isolate数量: 最好只有一个子线程在跑，多个会形成拥挤。
  static const int _maxIsolate = 1;
  /// 已经创建的数量
  static int _countIsolate = 0;
  /// 等待中的队列
  static final List<Map<SingleIsolate, IsolateHandler>> _waitIsolateList = [];
  /// isolate对象
  static late Isolate isolate;
  /// 子isolate SendPort
  static late SendPort subSendport;
  static late SendPort mainSendport;
  static bool isolateIsKill = true;

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

    if (!isolateIsKill) {
      log('init pre isolate...${isolate.controlPort.hashCode}, $_countIsolate, max:$_maxIsolate, wait: ${_waitIsolateList.length}');

      mapThreadHandler[mainSendport] = threadHandler;
      subSendport.send(mapThreadHandler);
      return;
    }
    log('init isolate...$_countIsolate, max:$_maxIsolate, wait: ${_waitIsolateList.length}');


    ReceivePort receivePort = ReceivePort();
    receivePort.listen((data) {
      log('isolate listen data: $data, wait:${_waitIsolateList.isEmpty}, ${receivePort.sendPort.hashCode}');
      if (data is SendPort) {
        SendPort sendPort = data;
        sendPort.send(mapThreadHandler);
        subSendport = sendPort;
        return;
      }
      try {
        // 避免处理异常了，没有销毁资源
        mainHandler(data);
      }catch (e) {
        log('mainHandler error: $e');
      }
      mapThreadHandler.remove(receivePort.sendPort);
      // if (_waitIsolateList.isEmpty) {
      //   // 一次性的数据处理完成了，需要销毁资源
      //   receivePort.close();
      //   subSendport.send('close');
      //   // isolate.kill();
      //   isolateIsKill = true;
      // }
      disposeNext();

    });
    mainSendport = receivePort.sendPort;
    mapThreadHandler[receivePort.sendPort] = threadHandler;
    isolate = await Isolate.spawn(_sendPortHandler, receivePort.sendPort);
    isolateIsKill = false;
  }

  void disposeNext() {
    _countIsolate--;
    if (_waitIsolateList.isNotEmpty) {
      var entity = _waitIsolateList.first.keys.first;
      var handler = _waitIsolateList.first.values.first;
      entity.init(threadHandler: handler.threadHandler, mainHandler: handler.mainHandler);
      _waitIsolateList.removeAt(0);
    }else {
      // 这里杀掉了，所有的ReceivePort也就没有了
      isolate.kill();
      isolateIsKill = true;
    }
  }

  /// 这里调用的数据是不共享的, 需要通过port共享数据
  static void _sendPortHandler(SendPort sendPort) {
    ReceivePort receivePort = ReceivePort();
    receivePort.listen((data) {
      log('_sendPortHandler listen data: $data, ${sendPort.hashCode}');
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
        return;
      }else if (data == 'close') {
        // 任务完成了，就关闭吧
        receivePort.close();
      }
    });
    sendPort.send(receivePort.sendPort);
  }
}
