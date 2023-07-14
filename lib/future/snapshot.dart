enum ConnectionState {
  none,

  waiting,

  active,

  done,
}


class AsyncSnapshot<T> {
  const AsyncSnapshot._(this.connectionState, this.data, this.error, this.stackTrace)
      : assert(connectionState != null),
        assert(!(data != null && error != null)),
        assert(stackTrace == null || error != null);

  const AsyncSnapshot.nothing() : this._(ConnectionState.none, null, null, null);

  const AsyncSnapshot.waiting() : this._(ConnectionState.waiting, null, null, null);

  const AsyncSnapshot.withData(ConnectionState state, T data): this._(state, data, null, null);

  const AsyncSnapshot.withError(
      ConnectionState state,
      Object error, [
        StackTrace stackTrace = StackTrace.empty,
      ]) : this._(state, null, error, stackTrace);

  final ConnectionState connectionState;

  final T? data;

  T get requireData {
    if (hasData)
      return data!;
    if (hasError)
      Error.throwWithStackTrace(error!, stackTrace!);
    throw StateError('Snapshot has neither data nor error');
  }

  final Object? error;

  final StackTrace? stackTrace;

  AsyncSnapshot<T> inState(ConnectionState state) => AsyncSnapshot<T>._(state, data, error, stackTrace);

  bool get hasData => data != null;

  bool get hasError => error != null;

  // @override
  // String toString() => '${objectRuntimeType(this, 'AsyncSnapshot')}($connectionState, $data, $error, $stackTrace)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other))
      return true;
    return other is AsyncSnapshot<T>
        && other.connectionState == connectionState
        && other.data == data
        && other.error == error
        && other.stackTrace == stackTrace;
  }

  // @override
  // int get hashCode => hashValues(connectionState, data, error);
}