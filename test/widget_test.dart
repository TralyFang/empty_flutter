// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:empty_flutter/completer.dart';
import 'package:empty_flutter/controller.dart' as actr;
import 'package:empty_flutter/getx/controller.dart' as bctr;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:empty_flutter/main.dart';

void main() {

  bool subContain(Set<String> set, String router) {
    return set.where((String element) => element.contains(router)).isNotEmpty;
    return set.map((String e) => e.contains(router)).toList().contains(true);
  }

  test('toString', (){
    var ctr = actr.EasyXController();
    expect(ctr.toString(), 'Instance of \'EasyXController\'');
    expect(ctr.runtimeType.toString(), 'EasyXController');

    var b = bctr.EasyXController();
    expect(b.toString(), 'Instance of \'EasyXController\'');
    expect(b.runtimeType, bctr.EasyXController);
    expect(b.runtimeType, 'EasyXController');

  });

  test('list remove', (){
    var list2 = ['flutter://re_login', 'flutter://login_indoor/false', 'flutter://index_page', 'flutter://index_page'];
    // list2.remove('flutter://index_page');
    list2.removeWhere((element) => element=='flutter://index_page');
    expect(list2, ['flutter://re_login', 'flutter://login_indoor/false']);

  });

  test('set remove', (){
    Set<String> list2 = {'flutter://re_login', 'flutter://login_indoor/false', 'flutter://index_page', 'flutter://index_page'};
    list2.remove('flutter://index_page');
    // list2.removeWhere((element) => element=='flutter://index_page');
    expect(list2, {'flutter://re_login', 'flutter://login_indoor/false'});

    expect(subContain(list2, 'login_indoor'), true);
    expect(subContain(list2, 'login_indoor1'), false);

  });

  test('list.firstWhere', (){
    List<int?> list = List.filled(10, null);
    int? value = list.firstWhere((element) => element == 3, orElse: ()=> null);
    expect(value, null);
  });


  test('++_++', (){

    int count = 0;
    int countP = ++count;
    expect(count, 1);
    expect(countP, 1);

    count = 0;
    int countB = count++;
    expect(count, 1);
    expect(countB, 0);

  });

  test('cast<R>', (){
    List<dynamic> list = ['1','2','3', 4];
    try {
      List<String> cast = list.cast<String>();
      print('matcher: $cast, $list');
    }catch (e) {
      // object:type 'int' is not a subtype of type 'String' in type cast
      print('object:${e.toString()}');
    }

  });

  test('reduce', (){
    var list = <int>[1];
    var reduce = list.reduce((value, element) => value + element);
    expect(reduce, 1);
    /*
dart:collection              ListMixin.reduce
test/widget_test.dart 20:23  main.<fn>

Bad state: No element
* */
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });

  test('chain', (){
    List<int> ints = [1,2,3,8,4,7,3];

    // Future.delayed(duration)
    //
    // List<int> reverse(List<int> ints) {
    //   List<int>? prev;
    //   List<int>? current = ints;
    //   while (current != null) {
    //     List<int>? next = current.iterator.current;
    //     current._nextListener = prev;
    //     prev = current;
    //     current = next;
    //   }
    //   return prev;
    // }

  });

  Future doSomething() {
    final Completer completer = Completer<String>();
    Future future = completer.future;
    print('future:${DateTime.now()}');
    future = AsyncOperation<String>().doOperation();
    Future.delayed(const Duration(milliseconds: 1000),(){
      print('future delayed:${DateTime.now()}');
    });
    print('future complete1:${DateTime.now()}');
    completer.complete('String');
    print('future complete2:${DateTime.now()}');
    AsyncOperation<String>().doOperation().then((value) {
      print('future AsyncOperation:${DateTime.now()}');
    });
    return future;
  }

  test('classExtends', (){
    // C c = C();
    // c.run(); // 如果多继承，该执行哪个基类的 run 方法 ??

    doSomething().then((value) {
      print('then:${DateTime.now()}');
    });

  });




}

class A{
  final String name;

  A(this.name);

  void run(){  print("B"); }
}

class B{
  final String name;

  B(this.name);

  void run(){ print("B"); }
}

class C implements A , B {
  @override
  String get name => 'C';

  @override
  void run() {
    // TODO: implement run
  }

  // @override
  // set name(String _name) {
  //   // TODO: implement name
  // }

// C(String name) : super(name); // 如果多继承，该为哪个基类的 name 成员赋值 ??
}

/*
abstract class A{
  void run() {
    print("A");
  }
}

abstract class B{
  void run() {
    print("B");
  }
}

class C implements A,B{
  @override
  void run() {
  }
}

 */