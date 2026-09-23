import 'package:flutter/material.dart';

/// Centralized animation durations and curves to maintain a fast, smooth rhythm.
class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration logoStage = Duration(milliseconds: 650);
  static const Duration splashTotal = Duration(milliseconds: 3200);

  // Curves
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve bounceSubtle = Curves.easeOutBack;
}
