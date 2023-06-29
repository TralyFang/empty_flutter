import 'dart:async';

// 对状态根据操作进行处理，并返回状态：状态加工
typedef Reducer<State> = State Function(State state, dynamic action);

// 等同于typedef
abstract class ReducerClass<State> {
  State call(State state, dynamic action);
}

// 中间状态处理：需要调用next才能让链路传递下去，
typedef Middleware<State> = dynamic Function(Store<State> store, dynamic action, NextDispatcher next);

abstract class MiddlewareClass<State> {
  dynamic call(Store<State> store, dynamic action, NextDispatcher next);
}

typedef NextDispatcher = dynamic Function(dynamic action);


class Store<State> {

  // 状态加工
  Reducer<State> reducer;

  final StreamController<State> _changeController;
  late State _state;
  late final List<NextDispatcher> _dispatchers;

  Store(
      this.reducer, {
        required State initialState,
        List<Middleware<State>> middleware = const [],
        bool syncStream = false, // false: 异步流通知，true：同步流通知
        bool distinct = false, // false: 状态改变了，才通知回调。 true：只要dispatch就通知回调
      }) : _changeController = StreamController.broadcast(sync: syncStream) {
    _state = initialState;
    _dispatchers = _createDispatchers(
      middleware,
      _createReduceAndNotify(distinct),
    );
  }

  State get state => _state;

  Stream<State> get onChange => _changeController.stream;

  // 创建一个状态加工和通知的分发器，需要事件才能分发
  NextDispatcher _createReduceAndNotify(bool distinct) {
    return (dynamic action) {
      final state = reducer(_state, action);

      if (distinct && state == _state) return;

      print('reducer.state:$state');
      _state = state;
      _changeController.add(state);
    };
  }

  // 一系列的分发器，还有一系列的中间件
  List<NextDispatcher> _createDispatchers(
      List<Middleware<State>> middleware,
      NextDispatcher reduceAndNotify,
      ) {
    // 分发器需要经过中间件处理之后才能分发。
    final dispatchers = <NextDispatcher>[reduceAndNotify];

    // 将一系列的分发器与中间件串联起来。
// -2 -1
    // middle: 0 1 2 --> 2 1 0
    for (var nextMiddleware in middleware.reversed) {
      final next = dispatchers.last; // [-1, 2], [2, 1], [1, 0], [0, -1]
      dispatchers.add(
            (dynamic action) => nextMiddleware(this, action, next),
      );
      //-1 2 1 0
    }
    // 0 1 2 -1 -2
    return dispatchers.reversed.toList();
  }

  dynamic dispatch(dynamic action) {
    print('dispatchs.action:$action, $_dispatchers');
    // 从第一链路传递下去
    return _dispatchers[0](action);
  }

  // 关闭流控制器
  Future teardown() async {
    return _changeController.close();
  }
}














// 根据操作触发状态处理
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

// 根据操作触发中间件处理
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

// 串联状态处理
Reducer<State> combineReducers<State>(Iterable<Reducer<State>> reducers) {
  return (State state, dynamic action) {
    for (final reducer in reducers) {
      state = reducer(state, action);
    }
    return state;
  };
}