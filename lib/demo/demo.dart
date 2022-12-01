class Demo {
  nullTest() {
    List<int?> list = List.filled(10, null);
    int? value = list.firstWhere((element) => element == 3, orElse: ()=> null);


    int jellyMax = 10;
    List<Vec2D?> jellyPoints = [
      for (var i = 0; i <= jellyMax; i++)
        Vec2D() // Each list element is a distinct Vec2D
    ];

    jellyPoints = List<Vec2D?>.filled(jellyMax + 1, null, growable: false);
    for (var i = 0; i <= jellyMax; i++) {
      jellyPoints[i] = Vec2D(); // Each list element is a distinct Vec2D
    }
  }


}

class Vec2D {

}


// Using null safety, incorrectly:
class Coffee {
  String? _temperature;

  void heat() { _temperature = 'hot'; }
  void chill() { _temperature = 'iced'; }

  void checkTemp() {
    if (_temperature != null) {
      /*
      * 在 checkTemp() 中，我们检查了 _temperature 是否为 null。
      * 如果不为空，我们会访问并对它调用 +。很遗憾，这样做是不被允许的。
      * 基于流程分析的类型提升并不适用于字段，因为静态分析不能 证明 这个字段的值在你判断后和使用前没有发生变化。
      * （某些极端场景中，字段本身可能会被子类的 getter 重写，从而在第二次调用时返回 null。）
      *
      * */
      print('Ready to serve ' + _temperature! + '!');
    }

    var temperature = _temperature;
    if (temperature != null) {
      print('Ready to serve ' + temperature + '!');
    }
  }

  String serve() => _temperature! + ' coffee';
}