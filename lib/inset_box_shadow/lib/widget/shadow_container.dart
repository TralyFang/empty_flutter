import 'package:flutter/material.dart' hide BoxDecoration, BoxShadow;
import '../inset_box_shadow/flutter_inset_box_shadow.dart';

class ShadowContainer extends StatelessWidget {
  final Size size;
  final Color color;
  final double borderRadius;
  final List<BoxShadow> shadowList;
  final Gradient gradient;
  final Widget? child;

  const ShadowContainer({
    Key? key,
    required this.size,
    required this.color,
    this.borderRadius = 20,
    required this.shadowList,
    required this.gradient,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          boxShadow: shadowList),
      child: child,
    );
  }
}
