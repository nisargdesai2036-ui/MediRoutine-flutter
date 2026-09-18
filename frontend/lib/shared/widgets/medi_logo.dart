import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Static vector rendering of the MediRoutine logo glyph.
class MediLogo extends StatelessWidget {
  final double size;
  final bool showGlow;

  const MediLogo({super.key, this.size = 56.0, this.showGlow = true});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MediLogoPainter(showGlow: showGlow),
    );
  }
}

class _MediLogoPainter extends CustomPainter {
  final bool showGlow;

  _MediLogoPainter({required this.showGlow});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Subtle ambient back-glow
    if (showGlow) {
      final glowPaint = Paint()
        ..color = AppColors.primaryLight.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0);
      canvas.drawCircle(center, radius * 0.85, glowPaint);
    }

    final gradient = const LinearGradient(
      colors: [Color(0xFFC084FC), Color(0xFF7C3AED), Color(0xFF38BDF8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(rect);

    // 1. Outer rounded container/capsule path
    final strokeWidth = size.width * 0.085;
    final strokePaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.82,
        height: size.height * 0.82,
      ),
      Radius.circular(size.width * 0.28),
    );

    // Draw subtle container background
    final bgPaint = Paint()
      ..color = AppColors.surfaceElevated.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, bgPaint);

    // Draw container boundary
    final containerBorderPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.25),
          AppColors.primaryLight.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(rrect, containerBorderPaint);

    // 2. Inner M-pulse stylized medical geometry
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start left node
    final p1 = Offset(w * 0.26, h * 0.60);
    final p2 = Offset(w * 0.36, h * 0.38);
    final p3 = Offset(w * 0.50, h * 0.54);
    final p4 = Offset(w * 0.64, h * 0.38);
    final p5 = Offset(w * 0.74, h * 0.60);

    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.lineTo(p4.dx, p4.dy);
    path.lineTo(p5.dx, p5.dy);

    canvas.drawPath(path, strokePaint);

    // 3. Central luminous sync dot / pulse beacon
    final dotPaint = Paint()
      ..color = AppColors.accentCyan
      ..style = PaintingStyle.fill;

    canvas.drawCircle(p3, strokeWidth * 0.45, dotPaint);

    // Subtle dot glow
    final dotGlow = Paint()
      ..color = AppColors.accentCyan.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    canvas.drawCircle(p3, strokeWidth * 0.8, dotGlow);
  }

  @override
  bool shouldRepaint(covariant _MediLogoPainter oldDelegate) {
    return oldDelegate.showGlow != showGlow;
  }
}
