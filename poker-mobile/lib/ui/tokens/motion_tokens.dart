// Poker Sharp — Motion Tokens

import 'package:flutter/animation.dart';

abstract final class AppMotion {
  // Durations
  static const instant = Duration(milliseconds: 80);
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 180);
  static const medium = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 320);
  static const emphasis = Duration(milliseconds: 420);

  // Easings
  static const Curve standard = Curves.easeInOut;
  static const Curve entrance = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve linear = Curves.linear;
}
