import 'dart:async';
import 'dart:isolate';

import 'worker.dart';

typedef ParallelCallback<T, R> = FutureOr<R> Function({T? item});
/// 这个代码是非常值得学习的地方，而且设计思想也非常值得学习！
class Parallel {
  static FutureOr<R> run<T, R>(ParallelCallback<T, R> handler,
      {T? entryValue}) async {
    final completer = Completer();
    final worker = Worker();
    await worker.init(
      (data, _) {
        completer.complete(data);
        worker.dispose();
      },
      _isolateHandler,
      initialMessage: _ParallelRunParams<T, R>(entryValue, handler),
    );
    return await completer.future;
  }

  static FutureOr<List<R>> map<T, R>(
      List<T> values, FutureOr<R> Function(T item) handler) async {
    final completerList =
        Map.fromIterables(values, values.map((e) => Completer()));

    for (final item in values) {
      final worker = Worker();
      await worker.init(
        (data, _) {
          completerList[item]?.complete(data);
          worker.dispose();
        },
        _isolateHandler,
        initialMessage: _ParallelMapParams(item, handler),
      );
    }

    final result = await Future.wait(completerList.values.map((e) => e.future));
    return result.cast<R>();
  }

  static FutureOr<void> foreach<T>(
      List<T> values, FutureOr<void> Function(T item) handler) async {
    final completerList =
        Map.fromIterables(values, values.map((e) => Completer()));

    for (final item in values) {
      final worker = Worker();
      await worker.init(
        (data, _) {
          completerList[item]?.complete(null);
          worker.dispose();
        },
        _isolateHandler,
        initialMessage: _ParallelForeachParams(item, handler),
      );
    }

    await Future.wait(completerList.values.map((e) => e.future));
  }

  static void _isolateHandler(
      event, SendPort mainSendPort, SendErrorFunction? sendError) async {
    if (event is _ParallelMapParams) {
      final result = await event.apply();
      mainSendPort.send(result);
    } else if (event is _ParallelForeachParams) {
      await event.apply();
      mainSendPort.send(null);
    } else if (event is _ParallelRunParams) {
      final result = await event.apply();
      mainSendPort.send(result);
    }
  }
}

class _ParallelMapParams<T, R> {
  final T item;
  final FutureOr<R> Function(T item) handler;

  FutureOr<R> apply() => handler(item);

  _ParallelMapParams(this.item, this.handler);
}

class _ParallelForeachParams<T> {
  final dynamic item;
  final FutureOr<void> Function(T item) handler;

  FutureOr<void> apply() => handler(item);

  _ParallelForeachParams(this.item, this.handler);
}

/// 这个类的设计也非常有意思！！！
class _ParallelRunParams<T, R> {
  final T? item;
  final ParallelCallback<T, R> _handler;

  FutureOr<R> apply() => _handler(item: item);

  _ParallelRunParams(this.item, this._handler);
}
