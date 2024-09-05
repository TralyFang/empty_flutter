
// ModalBarrier
// 它主要用来当作蒙板覆盖在页面上方,该组件类似Dialog组件，不过它默认情况会覆盖整个页面，因此需要在它外层
// 嵌套一个容器来控制它的大小。本章回中将详细介绍该组件的使用方法。

import 'package:flutter/material.dart';

class Demo {
  static void main() {
    Stack(
      children: [
        Opacity(
          opacity: 0.3,
          child: const ModalBarrier(dismissible: false, color: Colors.grey),
        ),
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}