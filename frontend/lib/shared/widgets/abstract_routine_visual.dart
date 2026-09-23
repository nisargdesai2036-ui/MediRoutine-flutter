import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// A restrained, elegant custom-painted visual representing MediRoutine's core concepts:
/// daily routine cycles, rhythmic time progression, dose continuity, and adherence.
class AbstractRoutineVisual extends StatefulWidget {
  final double size;

  const AbstractRoutineVisual({super.key, this.size = 380.0});

  @override
  State<AbstractRoutineVisual> createState() => _AbstractRoutineVisualState();
}

class _AbstractRoutineVisualState extends State<AbstractRoutineVisual>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _RoutineSculpturePainter(progress: _controller.value),
          ),
        );
      },
    );
  }
}

class _RoutineSculpturePainter extends CustomPainter {
  final double progress;

  _RoutineSculpturePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;

    // 1. Soft Ambient Radial Backdrop Aura
    final auraPaint = Paint()
      ..color = AppColors.brandPrimary.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48.0);
    canvas.drawCircle(center, radius * 0.85, auraPaint);

    final cyanAura = Paint()
      ..color = AppColors.brandCyan.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 36.0);
    canvas.drawCircle(
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.3),
      radius * 0.6,
      cyanAura,
    );

    // 2. Precision Concentric Dial Ticks (Subtle medical timepiece / 24h rhythm)
    final tickPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.0;

    const tickCount = 24;
    for (int i = 0; i < tickCount; i++) {
      final angle = (i / tickCount) * 2 * math.pi;
      final isMajor = i % 6 == 0;
      final outerR = radius * 0.98;
      final innerR = isMajor ? radius * 0.90 : radius * 0.94;

      final p1 = Offset(
        center.dx + math.cos(angle) * innerR,
        center.dy + math.sin(angle) * innerR,
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * outerR,
        center.dy + math.sin(angle) * outerR,
      );

      if (isMajor) {
        tickPaint.color = AppColors.brandLavender.withValues(alpha: 0.35);
        tickPaint.strokeWidth = 1.4;
      } else {
        tickPaint.color = Colors.white.withValues(alpha: 0.08);
        tickPaint.strokeWidth = 0.8;
      }
      canvas.drawLine(p1, p2, tickPaint);
    }

    // 3. Primary Harmonious Orbit (Daily Routine Continuum)
    final orbitRect = Rect.fromCenter(
      center: center,
      width: radius * 1.8,
      height: radius * 1.8,
    );
    final orbitPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          AppColors.brandPrimary.withValues(alpha: 0.1),
          AppColors.brandPrimary,
          AppColors.brandCyan,
          AppColors.brandLavender,
          AppColors.brandPrimary.withValues(alpha: 0.1),
        ],
        transform: GradientRotation(progress * 2 * math.pi),
      ).createShader(orbitRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius * 0.78, orbitPaint);

    // 4. Secondary Counter-Orbit with Soft Depth
    final counterOrbitPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          AppColors.brandCyan.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(orbitRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-progress * math.pi * 0.5);
    final secondaryRect = Rect.fromCenter(
      center: Offset.zero,
      width: radius * 1.35,
      height: radius * 0.95,
    );
    canvas.drawOval(secondaryRect, counterOrbitPaint);
    canvas.restore();

    // 5. Three Routine Rhythm Nodes (Morning, Midday, Evening)
    final nodeAngles = [
      (0.20 + progress * 0.1) * 2 * math.pi, // Morning
      (0.55 + progress * 0.1) * 2 * math.pi, // Midday
      (0.85 + progress * 0.1) * 2 * math.pi, // Evening
    ];

    final nodeColors = [
      AppColors.brandLavender,
      AppColors.brandCyan,
      const Color(0xFFC084FC),
    ];

    for (int i = 0; i < 3; i++) {
      final ang = nodeAngles[i];
      final r = radius * 0.78;
      final nodePos = Offset(
        center.dx + math.cos(ang) * r,
        center.dy + math.sin(ang) * r,
      );

      // Node Glow
      final nodeGlow = Paint()
        ..color = nodeColors[i].withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawCircle(nodePos, 7.0, nodeGlow);

      // Solid Node Center
      final nodePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(nodePos, 3.2, nodePaint);

      final nodeRing = Paint()
        ..color = nodeColors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;
      canvas.drawCircle(nodePos, 5.8, nodeRing);
    }

    // 6. Central Geometric Synchronicity Glyph (Minimalist Capsule & Pulse)
    final capsuleR = radius * 0.32;
    final capsuleRect = Rect.fromCenter(
      center: center,
      width: capsuleR * 1.5,
      height: capsuleR * 0.85,
    );
    final capsuleRRect = RRect.fromRectAndRadius(
      capsuleRect,
      Radius.circular(capsuleR * 0.42),
    );

    // Inner Glass Fill
    final capsuleBg = Paint()
      ..color = AppColors.brandSurfaceElevated.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(capsuleRRect, capsuleBg);

    // Subtle Outline
    final capsuleBorder = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.3),
          AppColors.brandPrimary.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(capsuleRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(capsuleRRect, capsuleBorder);

    // Subtle Pulse Waveform through Center
    final wavePath = Path();
    final cw = capsuleR * 1.1;
    final ch = capsuleR * 0.35;
    final ox = center.dx - cw / 2;
    final oy = center.dy;

    wavePath.moveTo(ox, oy);
    wavePath.lineTo(ox + cw * 0.30, oy);
    wavePath.lineTo(ox + cw * 0.42, oy - ch);
    wavePath.lineTo(ox + cw * 0.58, oy + ch);
    wavePath.lineTo(ox + cw * 0.70, oy);
    wavePath.lineTo(ox + cw, oy);

    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.brandCyan, AppColors.brandLavender],
      ).createShader(capsuleRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant _RoutineSculpturePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
