import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

class A11yScrollBehavior extends MaterialScrollBehavior {
  const A11yScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.unknown,
      };
}
