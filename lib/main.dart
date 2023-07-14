import 'dart:async';
import 'dart:convert';

import 'package:empty_flutter/completer.dart';
import 'package:empty_flutter/future/future.dart';
import 'package:empty_flutter/isolate/isolate.dart';
import 'package:empty_flutter/mounted/mounted_animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'get_it/get_it_demo.dart';
import 'mounted/nav_observers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [YBDRouteObserver()],
      routes: <String, WidgetBuilder>{
        SecondPage.routeName: (_) => const SecondPage(''),
        "/initialRoute": (_) => const MyApp(),
        'HomePage.routeName': (_) => MountedAnimation(),
      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);



  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  double angle = 0;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;


  @override
  void initState() {
    UserHandler.initHandler();
    super.initState();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animationController.addListener(() {
      setState(() {});
    });

    CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _rotationAnimation = Tween<double>(
        begin: 0.0, end: angle/360)
        .animate(curvedAnimation);
  }

  Future<void> _incrementCounter() async {

    angle += 60;

    CurvedAnimation curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    );

    _rotationAnimation = Tween<double>(
        begin: 0.0, end: angle/360 + 3)
        .animate(curvedAnimation);

    _animationController.reset();
    _animationController.forward();

    setState(() {
      _counter++;
    });


  }

  Future doSomething() {
    final Completer completer = Completer<String>();
    Future future = completer.future;
    print('future:${DateTime.now()}');
    future = AsyncOperation<String>().doOperation();
    print('future complete1:${DateTime.now()}');
    completer.complete('String');
    print('future complete2:${DateTime.now()}');
    return future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter,$angle,${angle/360.0},${angle%360.0},${angle~/360.0}',
              style: Theme.of(context).textTheme.headline4,
            ),
            // if (true) _ttimeBBuilder(),
            // if (_counter % 2 == 0) PageTwo(),
            // UserInfoWidget(),
            RotationTransition(
              alignment: Alignment.bottomCenter,
              turns: _rotationAnimation,// 角度
              child: Container(
                width: 100,
                height: 150,
                color: Colors.red,
                child: Text('data123'),
              ),
            ),
            Transform.rotate(
              angle: angle,
              alignment: Alignment.center,
              child: Container(
                width: 60,
                height: 50,
                color: Colors.yellow,
                child: Text('qwert'),
              ),
            )

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      )
    );
  }

  _ttimeBBuilder() {
    return Builder(builder: (BuildContext context) {
      print('${DateTime.now()} start');
      var jsonDict = null;
      int re = 0;
      for (int i = 0; i < 100000; i++) {
        int cc = i * 2 + 300;
        re += (cc + 3);
        jsonDict = jsonDecode("""
                      {"name":"nickname"}
                      """);
      }
      re += _counter;
      print('${DateTime.now()} end, re:$re, $jsonDict');
      return Text('$re, $jsonDict');
    });
  }
}

class PageTwo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.greenAccent,
      child: Center(
        child: Text(
          '第2页 ' + _fibonacci(30).toString(),
          style: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
      ),
    );
  }

  static int _fibonacci(int i) {
    if (i <= 1) return i;
    return _fibonacci(i - 1) + _fibonacci(i - 2);
  }

  void _hello() {

  }
}
