import 'package:flutter/animation.dart';

/// Shared timing for the Bold design's short, interruptible UI transitions.
abstract final class BoldMotion {
  static const micro = Duration(milliseconds: 180);
  static const screen = Duration(milliseconds: 320);
  static const screenReverse = Duration(milliseconds: 260);
  static const content = Duration(milliseconds: 420);

  static const enter = Curves.easeOutCubic;
  static const exit = Curves.easeInCubic;
}
