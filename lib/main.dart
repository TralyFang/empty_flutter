import 'dart:async';
import 'dart:convert';

import 'package:empty_flutter/completer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;

  @override
  void initState() {
    super.initState();

  }

  Future<void> _incrementCounter() async {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });

    doSomething().then((value) {
      print('then:${DateTime.now()}: $value');
    });
  }

  Future doSomething() {
    final Completer completer = Completer<String>();
    Future future = completer.future;
    print('future:${DateTime.now()}');
    future = AsyncOperation<String>().doOperation();
    // future = Future.delayed(const Duration(milliseconds: 1000));
    // Future.delayed(const Duration(milliseconds: 1000),(){
    //   print('future delayed:${DateTime.now()}');
    // });
    print('future complete1:${DateTime.now()}');
    completer.complete('String');
    print('future complete2:${DateTime.now()}');
    // AsyncOperation<String>().doOperation().then((value) {
    //   print('future AsyncOperation:${DateTime.now()}');
    // });
    return future;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
            if (true)
              _ttimeBBuilder(),
            if (_counter % 2 == 0)
              PageTwo(),
          ],

        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _ttimeBBuilder() {
    return Builder(
        builder: (BuildContext context) {

          print('${DateTime.now()} start');
          var jsonDict = null;
          int re = 0;
          for (int i=0; i< 100000; i++) {
            int cc = i*2 + 300;
            re += (cc + 3);
            jsonDict = jsonDecode("""
                      {"name":"nickname"}
                      """);
          }
          re += _counter;
          print('${DateTime.now()} end, re:$re, $jsonDict');
          return Text('$re, $jsonDict');});
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
    if(i <= 1) return i;
    return _fibonacci(i - 1) + _fibonacci(i - 2);
  }
}