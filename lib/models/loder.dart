import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyAppLoader extends StatelessWidget {
  final double size;
  const MyAppLoader({this.size = 50});

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.fourRotatingDots(
      color: Color.fromARGB(255, 0, 0, 0),
      size: size,
    );
  }
}
