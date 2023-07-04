// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

abstract class Emitter<State> {
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T data) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  });

  // Subscribes to the provided [stream] and invokes the [onData] callback
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T data) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  });

  bool get isDone;

  void call(State state);
}

typedef EventHandler<Event, State> = FutureOr<void> Function(
  Event event,
  Emitter<State> emit,
);

typedef EventMapper<Event> = Stream<Event> Function(Event event);

typedef EventTransformer<Event> = Stream<Event> Function(
  Stream<Event> events,
  EventMapper<Event> mapper,
);

class _Emitter<State> implements Emitter<State> {
  _Emitter(this._emit);

  final void Function(State) _emit;
  final _completer = Completer<void>();
  final _disposables = <FutureOr<void> Function()>[];

  var _isCanceled = false;
  var _isCompleted = false;

  @override
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    final completer = Completer<void>();
    final subscription = stream.listen(
      onData,
      onDone: completer.complete,
      onError: onError ?? completer.completeError,
      cancelOnError: onError == null,
    );
    _disposables.add(subscription.cancel);
    return Future.any([future, completer.future]).whenComplete(() {
      subscription.cancel();
      _disposables.remove(subscription.cancel);
    });
  }

  @override
  Future<void> forEach<T>(
    Stream<T> stream, {
    required State Function(T) onData,
    State Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return onEach<T>(
      stream,
      onData: (data) => call(onData(data)),
      onError: onError != null
          ? (Object error, StackTrace stackTrace) {
              call(onError(error, stackTrace));
            }
          : null,
    );
  }

  @override
  void call(State state) {
    assert(
      !_isCompleted,
      '''\n\n
emit was called after an event handler completed normally.
This is usually due to an unawaited future in an event handler.
Please make sure to await all asynchronous operations with event handlers
and use emit.isDone after asynchronous operations before calling emit() to
ensure the event handler has not completed.

  **BAD**
  on<Event>((event, emit) {
    future.whenComplete(() => emit(...));
  });

  **GOOD**
  on<Event>((event, emit) async {
    await future.whenComplete(() => emit(...));
  });
''',
    );
    if (!_isCanceled) _emit(state);
  }

  @override
  bool get isDone => _isCanceled || _isCompleted;

  void cancel() {
    if (isDone) return;
    _isCanceled = true;
    _close();
  }

  void complete() {
    if (isDone) return;
    assert(
      _disposables.isEmpty,
      '''\n\n
An event handler completed but left pending subscriptions behind.
This is most likely due to an unawaited emit.forEach or emit.onEach. 
Please make sure to await all asynchronous operations within event handlers.

  **BAD**
  on<Event>((event, emit) {
    emit.forEach(...);
  });  
  
  **GOOD**
  on<Event>((event, emit) async {
    await emit.forEach(...);
  });

  **GOOD**
  on<Event>((event, emit) {
    return emit.forEach(...);
  });

  **GOOD**
  on<Event>((event, emit) => emit.forEach(...));

''',
    );
    _isCompleted = true;
    _close();
  }

  void _close() {
    for (final disposable in _disposables) disposable.call();
    _disposables.clear();
    if (!_completer.isCompleted) _completer.complete();
  }

  Future<void> get future => _completer.future;
}

@Deprecated(
  'Use `on<Event>` with an `EventTransformer` instead. '
  'Will be removed in v8.0.0',
)
typedef TransitionFunction<Event, State> = Stream<Transition<Event, State>>
    Function(Event);

class BlocUnhandledErrorException implements Exception {
  BlocUnhandledErrorException(
    this.bloc,
    this.error, [
    this.stackTrace = StackTrace.empty,
  ]);

  final BlocBase bloc;

  final Object error;

  final StackTrace stackTrace;

  @override
  String toString() {
    return 'Unhandled error $error occurred in $bloc.\n'
        '$stackTrace';
  }
}

abstract class Bloc<Event, State> extends BlocBase<State> {
  Bloc(State initialState) : super(initialState) {
    _bindEventsToStates();
  }

  static BlocObserver observer = BlocObserver();

  static EventTransformer<dynamic> transformer = (events, mapper) {
    return events
        .map(mapper)
        .transform<dynamic>(const _FlatMapStreamTransformer<dynamic>());
  };

  StreamSubscription<Transition<Event, State>>? _transitionSubscription;

  final _eventController = StreamController<Event>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  final _handlerTypes = <Type>[];
  final _emitters = <_Emitter>[];

  void add(Event event) {
    if (_eventController.isClosed) return;
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  @protected
  @mustCallSuper
  void onEvent(Event event) {
    // ignore: invalid_use_of_protected_member
    observer.onEvent(this, event);
  }

  @Deprecated(
    'Use `on<Event>` with an `EventTransformer` instead. '
    'Will be removed in v8.0.0',
  )
  Stream<Transition<Event, State>> transformEvents(
    Stream<Event> events,
    TransitionFunction<Event, State> transitionFn,
  ) {
    return events.asyncExpand(transitionFn);
  }

  @visibleForTesting
  @override
  void emit(State state) => super.emit(state);

  void on<E extends Event>(
    EventHandler<E, State> handler, {
    EventTransformer<E>? transformer,
  }) {
    assert(() {
      final handlerExists = _handlerTypes.any((type) => type == E);
      if (handlerExists) {
        throw StateError(
          'on<$E> was called multiple times. '
          'There should only be a single event handler per event type.',
        );
      }
      _handlerTypes.add(E);
      return true;
    }());

    final _transformer = transformer ?? Bloc.transformer;
    final subscription = _transformer(
      _eventController.stream.where((event) => event is E).cast<E>(),
      (dynamic event) {
        void onEmit(State state) {
          if (isClosed) return;
          if (this.state == state && _emitted) return;
          onTransition(Transition(
            currentState: this.state,
            event: event as E,
            nextState: state,
          ));
          emit(state);
        }

        final emitter = _Emitter(onEmit);
        final controller = StreamController<E>.broadcast(
          sync: true,
          onCancel: emitter.cancel,
        );

        void handleEvent() async {
          void onDone() {
            emitter.complete();
            _emitters.remove(emitter);
            if (!controller.isClosed) controller.close();
          }

          try {
            _emitters.add(emitter);
            await handler(event as E, emitter);
          } catch (error, stackTrace) {
            onError(error, stackTrace);
          } finally {
            onDone();
          }
        }

        handleEvent();
        return controller.stream;
      },
    ).listen(null);
    _subscriptions.add(subscription);
  }

  @Deprecated('Use on<Event> instead. Will be removed in v8.0.0')
  Stream<State> mapEventToState(Event event) async* {}

  @protected
  @mustCallSuper
  void onTransition(Transition<Event, State> transition) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onTransition(this, transition);
  }

  @Deprecated(
    'Override `Stream<State> get stream` instead. Will be removed in v8.0.0',
  )
  Stream<Transition<Event, State>> transformTransitions(
    Stream<Transition<Event, State>> transitions,
  ) {
    return transitions;
  }

  @override
  @mustCallSuper
  Future<void> close() async {
    await _eventController.close();
    for (final emitter in _emitters) emitter.cancel();
    await Future.wait<void>(_emitters.map((e) => e.future));
    await Future.wait<void>(_subscriptions.map((s) => s.cancel()));
    await _transitionSubscription?.cancel();
    return super.close();
  }

  void _bindEventsToStates() {
    void assertNoMixedUsage() {
      assert(() {
        if (_handlerTypes.isNotEmpty) {
          throw StateError(
            'mapEventToState cannot be overridden in '
            'conjunction with on<Event>.',
          );
        }
        return true;
      }());
    }

    _transitionSubscription = transformTransitions(
      transformEvents(
        _eventController.stream,
        (event) => mapEventToState(event).map(
          (nextState) => Transition(
            currentState: state,
            event: event,
            nextState: nextState,
          ),
        ),
      ),
    ).listen(
      (transition) {
        if (transition.nextState == state && _emitted) return;
        try {
          assertNoMixedUsage();
          onTransition(transition);
          emit(transition.nextState);
        } catch (error, stackTrace) {
          onError(error, stackTrace);
        }
      },
      onError: onError,
    );
  }
}

abstract class Cubit<State> extends BlocBase<State> {
  Cubit(State initialState) : super(initialState);
}

abstract class BlocBase<State> {
  BlocBase(this._state) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onCreate(this);
  }

  StreamController<State>? __stateController;
  StreamController<State> get _stateController {
    return __stateController ??= StreamController<State>.broadcast();
  }

  State _state;

  bool _emitted = false;

  State get state => _state;

  Stream<State> get stream => _stateController.stream;

  bool get isClosed => _stateController.isClosed;

  @Deprecated(
    'Use stream.listen instead. Will be removed in v8.0.0',
  )
  StreamSubscription<State> listen(
    void Function(State)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return stream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  void emit(State state) {
    if (_stateController.isClosed) return;
    if (state == _state && _emitted) return;
    onChange(Change<State>(currentState: this.state, nextState: state));
    _state = state;
    _stateController.add(_state);
    _emitted = true;
  }

  @mustCallSuper
  void onChange(Change<State> change) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onChange(this, change);
  }

  @mustCallSuper
  void addError(Object error, [StackTrace? stackTrace]) {
    onError(error, stackTrace ?? StackTrace.current);
  }

  @protected
  @mustCallSuper
  void onError(Object error, StackTrace stackTrace) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onError(this, error, stackTrace);
    assert(() {
      throw BlocUnhandledErrorException(this, error, stackTrace);
    }());
  }

  @mustCallSuper
  Future<void> close() async {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onClose(this);
    await _stateController.close();
  }
}

class _FlatMapStreamTransformer<T> extends StreamTransformerBase<Stream<T>, T> {
  const _FlatMapStreamTransformer();

  @override
  Stream<T> bind(Stream<Stream<T>> stream) {
    /// bind 两个stream
    final controller = StreamController<T>.broadcast(sync: true);

    controller.onListen = () {
      final subscriptions = <StreamSubscription<dynamic>>[];

      final outerSubscription = stream.listen(
        (inner) {
          final subscription = inner.listen(
            controller.add,
            onError: controller.addError,
          );

          subscription.onDone(() {
            subscriptions.remove(subscription);
            if (subscriptions.isEmpty) controller.close();
          });

          subscriptions.add(subscription);
        },
        onError: controller.addError,
      );

      outerSubscription.onDone(() {
        subscriptions.remove(outerSubscription);
        if (subscriptions.isEmpty) controller.close();
      });

      subscriptions.add(outerSubscription);

      controller.onCancel = () {
        if (subscriptions.isEmpty) return null;
        final cancels = [for (final s in subscriptions) s.cancel()];
        return Future.wait(cancels).then((_) {});
      };
    };

    return controller.stream;
  }
}
