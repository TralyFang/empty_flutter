import 'dart:async';

// 对状态根据操作进行处理，并返回状态：状态加工
typedef Reducer<State> = State Function(State state, dynamic action);

// 等同于typedef
abstract class ReducerClass<State> {
  State call(State state, dynamic action);
}

// 中间状态处理：
typedef Middleware<State> = dynamic Function(Store<State> store, dynamic action, NextDispatcher next);

abstract class MiddlewareClass<State> {
  dynamic call(Store<State> store, dynamic action, NextDispatcher next);
}

typedef NextDispatcher = dynamic Function(dynamic action);


class Store<State> {

  Reducer<State> reducer;

  final StreamController<State> _changeController;
  late State _state;
  late final List<NextDispatcher> _dispatchers;

  Store(
      this.reducer, {
        required State initialState,
        List<Middleware<State>> middleware = const [],
        bool syncStream = false,
        bool distinct = false,
      }) : _changeController = StreamController.broadcast(sync: syncStream) {
    _state = initialState;
    _dispatchers = _createDispatchers(
      middleware,
      _createReduceAndNotify(distinct),
    );
  }

  State get state => _state;

  Stream<State> get onChange => _changeController.stream;

  NextDispatcher _createReduceAndNotify(bool distinct) {
    return (dynamic action) {
      final state = reducer(_state, action);

      if (distinct && state == _state) return;

      print('reducer.state:$state');
      _state = state;
      _changeController.add(state);
    };
  }

  List<NextDispatcher> _createDispatchers(
      List<Middleware<State>> middleware,
      NextDispatcher reduceAndNotify,
      ) {
    final dispatchers = <NextDispatcher>[reduceAndNotify];
// -1
    // middle: 0 1 2 --> 2 1 0
    for (var nextMiddleware in middleware.reversed) {
      final next = dispatchers.last; // [-1, 2], [2, 1], [1, 0], [0, -1]
      dispatchers.add(
            (dynamic action) => nextMiddleware(this, action, next),
      );
      //-1 2 1 0
    }
    // 0 1 2 -1
    return dispatchers.reversed.toList();
  }

  dynamic dispatch(dynamic action) {
    print('dispatchs.action:$action, $_dispatchers');
    return _dispatchers[0](action);
  }

  Future teardown() async {
    return _changeController.close();
  }
}















class TypedReducer<State, Action> implements ReducerClass<State> {

  final State Function(State state, Action action) reducer;

  TypedReducer(this.reducer);

  @override
  State call(State state, dynamic action) {
    if (action is Action) {
      return reducer(state, action);
    }

    return state;
  }
}

class TypedMiddleware<State, Action> implements MiddlewareClass<State> {

  final void Function(
      Store<State> store,
      Action action,
      NextDispatcher next,
      ) middleware;

  TypedMiddleware(this.middleware);

  @override
  dynamic call(Store<State> store, dynamic action, NextDispatcher next) {
    if (action is Action) {
      return middleware(store, action, next);
    } else {
      return next(action);
    }
  }
}

Reducer<State> combineReducers<State>(Iterable<Reducer<State>> reducers) {
  return (State state, dynamic action) {
    for (final reducer in reducers) {
      state = reducer(state, action);
    }
    return state;
  };
}