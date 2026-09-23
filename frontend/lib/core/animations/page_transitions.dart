import 'package:flutter/material.dart';
import 'app_animations.dart';

/// Smooth, elegant page route transition designed for MediRoutine.
class MediPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  MediPageRoute({required this.page, super.settings})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: AppAnimations.medium,
        reverseTransitionDuration: AppAnimations.fast,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: AppAnimations.easeOut,
            reverseCurve: AppAnimations.easeIn,
          );

          // Subtle slide upwards + fade in
          final slideTween = Tween<Offset>(
            begin: const Offset(0.0, 0.05),
            end: Offset.zero,
          ).chain(CurveTween(curve: AppAnimations.easeOut));

          final fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: AppAnimations.easeOut));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: curvedAnimation.drive(fadeTween),
              child: child,
            ),
          );
        },
      );
}
