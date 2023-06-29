import 'dart:async';
import 'package:empty_flutter/redux/easyRX.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

void main() {
  group('Middleware', () {
    test('are invoked by the store', () {
      final middleware = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware],
      );
      store.dispatch('test');
      expect(middleware.counter, equals(1));
    });

    test('are applied in the correct order', () {
      final middleware1 = IncrementMiddleware()..key='key1';
      final middleware2 = IncrementMiddleware()..key='key2';
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware1, middleware2],
        syncStream: true,
      );

      final order = <String>[];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.onChange.listen((event) {
        print('onchange:$event');
      });

      // 1 2 --->

      store.dispatch('test');
      /*
      dispatchs: [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
      object.call:hello, key:key1
      object.call:hello, key:key2
      object.state:test
      onchange:test
      object.callend:test, key:key2
      object.callend:test, key:key1
      */

      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(middleware1.counter, equals(1));
      expect(middleware2.counter, equals(1));

    });

    test('actions can be dispatched multiple times', () {
      final middleware1 = ExtraActionIncrementMiddleware()..key='111';
      final middleware2 = IncrementMiddleware()..key='222';
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware1, middleware2],
      );

      final order = <String>[];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));
      store.onChange.listen((event) {
        print('onchange:$event');
      });
      store.dispatch('test');
      print('order:$order');
      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('second'));
    });

    test('actions can be dispatched through entire chain', () {
      final middleware1 = ExtraActionIfDispatchedIncrementMiddleware();
      final middleware2 = IncrementMiddleware();
      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [middleware1, middleware2],
      );

      final order = <String>[];
      middleware1.invocations.listen((action) => order.add('first'));
      middleware2.invocations.listen((action) => order.add('second'));

      store.dispatch('test');

      expect(order[0], equals('first'));
      expect(order[1], equals('second'));
      expect(order[2], equals('first'));
      expect(order[3], equals('second'));

      expect(middleware1.counter, equals(2));
    });

    test('dispatch returns the value from middleware', () async {
      final passthrough = PassThroughMiddleware<String>();
      final thunk = ThunkMiddleware<String>();
      Future<void> thunkAction(Store<String> store) async {
        await Future<void>.delayed(Duration(milliseconds: 5));
        store.dispatch('changed');
      }

      final store = Store<String>(
        stringReducer,
        initialState: 'hello',
        middleware: [passthrough, thunk],
      );

      final awaitableAction = store.dispatch(thunkAction) as Future<void>;

      // Did not change yet
      expect(store.state, equals('hello'));
      await awaitableAction;
      // The effect has taken place
      expect(store.state, equals('changed'));

      /*

[passthrough, thunk]
Thunk action

dispatchs.action:Closure: (Store<String>) => Future<void>, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
PassThroughMiddleware Closure: (Store<String>) => Future<void>
ThunkMiddleware Closure: (Store<String>) => Future<void>
dispatchs.action:changed, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
PassThroughMiddleware changed
ThunkMiddleware changed
reducer.state:changed


[passthrough, thunk]

dispatchs.action:Closure: (Store<String>) => Future<void>, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
PassThroughMiddleware Closure: (Store<String>) => Future<void>
ThunkMiddleware Closure: (Store<String>) => Future<void>
reducer.state:not found
test/redux/middleware_test.dart 117:59  main.<fn>.<fn>
test/redux/middleware_test.dart 103:56  main.<fn>.<fn>

type 'Null' is not a subtype of type 'Future<void>' in type cast


[thunk, passthrough]
Thunk action

dispatchs.action:Closure: (Store<String>) => Future<void>, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
ThunkMiddleware Closure: (Store<String>) => Future<void>
dispatchs.action:changed, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
ThunkMiddleware changed
PassThroughMiddleware changed
reducer.state:changed


[thunk, passthrough]
passthrough action

dispatchs.action:Closure: (Store<String>) => Future<void>, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
ThunkMiddleware Closure: (Store<String>) => Future<void>
PassThroughMiddleware Closure: (Store<String>) => Future<void>
dispatchs.action:changed, [Closure: (dynamic) => dynamic, Closure: (dynamic) => dynamic, Closure: (dynamic) => Null]
ThunkMiddleware changed
PassThroughMiddleware changed
reducer.state:changed

      *
      * */
    });
  });
}
