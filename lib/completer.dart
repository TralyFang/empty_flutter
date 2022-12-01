import 'dart:async';

class AsyncOperation<T> {
  final Completer _completer = Completer<T>();

  Future<T> doOperation() {
    _startOperation();
    return _completer.future as Future<T>; // Send future object back to client.
  }

  void _startOperation() {

    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      _finishOperation('String===' as T);
    });
  }

  // Something calls this when the value is ready.
  void _finishOperation(T result) {
    print('AsyncOperation _finishOperation');
    _completer.complete(result);
  }

  // If something goes wrong, call this.
  void _errorHappened(error) {
    _completer.completeError(error);
  }

  void test() {
    AsyncOperation<String>().doOperation().then((value) => {

    });
  }
}
