import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MountedAnimation extends StatefulWidget {
  MountedAnimation({Key? key}) : super(key: key);

  @override
  _MountedAnimationState createState() => _MountedAnimationState();
}

class _MountedAnimationState extends State<MountedAnimation> with TickerProviderStateMixin {

  double scale = 0;

  String? _routeName;

  late AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();




    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 15));
    _controller.addListener(() {
      print('mounted:$mounted, value:${_controller.value}');
      // 系统的弹窗并不会阻止动画，包括回调，UI更新。
      // 目前仅验证了弹窗方式：showDialog，showModalBottomSheet
      if (mounted) setState(() {});
    });
    _controller.addStatusListener((status) {
      print('status:$status, value:${_controller.value}');

      // completed 一定会在这个时间后回调的，不会这个时间之前回调；
      // 换句话的意思就是，在动画的过程中push了新的界面，动画会被暂停，值会一直变更；
      // 如果在动画时间内再次回到动画界面，动画的当前值不会接着上次的值做变更，而是居于开始的时间到现在的时间占比值来开始
      // 即：duration：10s， 在3s的时候退出，当前动画值是0.3， 在7s再次回到动画界面，当前动画值是0.7；
      // 如果在15s回到动画界面，那会直接回调completed，当前动画值是1.0；
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
        // if (_controller.value == 1.0) _controller.reverse();
        // if (_controller.value == 0.0) _controller.forward();
      }
    });



    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _routeName = ModalRoute.of(context)?.settings.name;
      print('routeName:$_routeName');
      if (_routeName == 'HomePage.routeName' || _routeName == null) {
        _controller.reset();
        _controller.forward();
      }
      setState(() {
        scale = 5;
      });
    });


  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Animation'),
      ),
      body:
      Container(
        width: 50*_controller.value*5,
        height: 50*_controller.value*5,
        color: Colors.red,
      ),

/*
      AnimatedScale(
        scale: scale,
        duration: const Duration(seconds: 5),
        child: Container(
          width: 50,
          height: 50,
          color: Colors.red,
        ),
      ),

 */
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          if (_routeName == '/mountedAniation') {
            showModalBottomSheet(
                context: context, builder: (BuildContext context){
              return Container(width: 100, height: 4000, color: Colors.blue,);
            });

            Navigator.push(context,
                MaterialPageRoute(
                    settings: const RouteSettings(name: '/mountedAniation2', arguments: {'agr':'name'}),
                    builder: (context) => MountedAnimation()));
           return;
          }

          // 系统的弹窗并不会阻止动画，包括回调，UI更新。
          // 也可以由导航控制器监听到push和pop事件
          showDialog(
              routeSettings: const RouteSettings(name: '/showDialog'),
              context: context, builder: (BuildContext context){
            return Container(width: 100, height: 4000, color: Colors.blue,);
          });

          showModalBottomSheet(
              routeSettings: const RouteSettings(name: '/showModalBottomSheet'),
              context: context, builder: (BuildContext context){
            return Container(width: 100, height: 4000, color: Colors.blue,);
          });

          Navigator.push(context,
              MaterialPageRoute(
                settings: const RouteSettings(name: '/mountedAniation', arguments: {'agr':'name'}),
                  builder: (context) => MountedAnimation()));

          Navigator.pushNamed(context, 'HomePage.routeName');


        },
        tooltip: 'pop',
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class UnmoutedWidget extends StatelessWidget {
  const UnmoutedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MountedAnimation();
  }
}


class SecondPage extends StatefulWidget {
  const SecondPage(
      this.payload, {
        Key? key,
      }) : super(key: key);

  static const String routeName = '/secondPage';

  final String? payload;

  @override
  State<StatefulWidget> createState() => SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  String? _payload;
  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Second Screen with payload: ${_payload ?? ''}'),
    ),
    body: Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Go back!'),
      ),
    ),
  );
}