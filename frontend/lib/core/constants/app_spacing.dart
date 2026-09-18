import 'package:flutter/material.dart';

/// Spacing, radius, and elevation tokens for consistent layout metrics.
class AppSpacing {
  AppSpacing._();

  // Spacing Units
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
  static const double maxContentWidth = 440.0;

  // Border Radii
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  static const BorderRadius roundedSm = BorderRadius.all(
    Radius.circular(radiusSm),
  );
  static const BorderRadius roundedMd = BorderRadius.all(
    Radius.circular(radiusMd),
  );
  static const BorderRadius roundedLg = BorderRadius.all(
    Radius.circular(radiusLg),
  );
  static const BorderRadius roundedXl = BorderRadius.all(
    Radius.circular(radiusXl),
  );
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  // Insets
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: lg,
  );
  static const EdgeInsets paddingCard = EdgeInsets.all(xxl);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(
    horizontal: xxl,
    vertical: 16.0,
  );
  static const EdgeInsets paddingInput = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: 16.0,
  );
}
