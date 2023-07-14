import 'dart:async';
import 'dart:isolate';

class HandledIsolateMessenger {
  final void Function()? _onEstablishedConnection;

  final ReceivePort _port = ReceivePort();

  SendPort? _sendPortOverride;

  bool _connectionEstablished = false;

  late Stream<dynamic> _broadcast;

  ReceivePort get inPort => _port;

  SendPort get outPort => _sendPortOverride ?? _port.sendPort;

  bool get connectionEstablished => _connectionEstablished;

  Stream<dynamic> get broadcast => _broadcast;

  HandledIsolateMessenger({
    SendPort? remotePort,
    void Function()? onInitialized,
  }) : _onEstablishedConnection = onInitialized {
    _broadcast = _port.asBroadcastStream();
    if (remotePort != null) connectTo(remotePort);
  }

  void connectTo(SendPort sendPort) {
    _sendPortOverride = sendPort;
    _onEstablishedConnection?.call();
    _connectionEstablished = true;
  }

  void send(dynamic message) => outPort.send(message);

  void _listenResponse(dynamic message, void Function(dynamic) onData) {
    if (_sendPortOverride == null && message is SendPort) {
      connectTo(message);
    } else {
      onData(message);
    }
  }

  StreamSubscription<dynamic> listen(
    void Function(dynamic message) onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      _port.listen(
        (var message) => _listenResponse(message, onData),
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  void dispose() {
    _port.close();
  }
}
