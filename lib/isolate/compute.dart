



import 'dart:async';
import 'dart:developer';

import 'dart:isolate';

import 'package:flutter/foundation.dart';

/// The dart:io implementation of [isolate.compute].
/*
Future<R> compute<Q, R>(isolates.ComputeCallback<Q, R> callback, Q message, { String? debugLabel }) async {
  debugLabel ??= kReleaseMode ? 'compute' : callback.toString();
  final Flow flow = Flow.begin();
  Timeline.startSync('$debugLabel: start', flow: flow);
  final ReceivePort resultPort = ReceivePort();
  final ReceivePort exitPort = ReceivePort();
  final ReceivePort errorPort = ReceivePort();
  Timeline.finishSync();
  await Isolate.spawn<_IsolateConfiguration<Q, FutureOr<R>>>(
    _spawn,
    _IsolateConfiguration<Q, FutureOr<R>>(
      callback,
      message,
      resultPort.sendPort,
      debugLabel,
      flow.id,
    ),
    errorsAreFatal: true,
    onExit: exitPort.sendPort,
    onError: errorPort.sendPort,
  );
  final Completer<R> result = Completer<R>();
  errorPort.listen((dynamic errorData) {
    assert(errorData is List<dynamic>);
    if (errorData is List<dynamic>) {
      assert(errorData.length == 2);
      final Exception exception = Exception(errorData[0]);
      final StackTrace stack = StackTrace.fromString(errorData[1] as String);
      if (result.isCompleted) {
        Zone.current.handleUncaughtError(exception, stack);
      } else {
        result.completeError(exception, stack);
      }
    }
  });
  exitPort.listen((dynamic exitData) {
    if (!result.isCompleted) {
      result.completeError(Exception('Isolate exited without result or error.'));
    }
  });
  resultPort.listen((dynamic resultData) {
    assert(resultData == null || resultData is R);
    if (!result.isCompleted)
      result.complete(resultData as R);
  });
  await result.future;
  Timeline.startSync('$debugLabel: end', flow: Flow.end(flow.id));
  resultPort.close();
  exitPort.close();
  errorPort.close();
  Timeline.finishSync();
  return result.future;
}*/
