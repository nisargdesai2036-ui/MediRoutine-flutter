import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_spacing.dart';

/// Dynamic particle-to-glyph brand logo animation for MediRoutine.
class AnimatedMediLogo extends StatefulWidget {
  final double size;
  final bool showWordmark;
  final VoidCallback? onCompleted;
  final bool enableBreathing;

  const AnimatedMediLogo({
    super.key,
    this.size = 110.0,
    this.showWordmark = true,
    this.onCompleted,
    this.enableBreathing = true,
  });

  @override
  State<AnimatedMediLogo> createState() => _AnimatedMediLogoState();
}

class _AnimatedMediLogoState extends State<AnimatedMediLogo>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _particles = _generateParticles(28);

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _mainController.forward().then((_) {
      if (mounted) {
        if (widget.enableBreathing) {
          _pulseController.repeat(reverse: true);
        }
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<_Particle> _generateParticles(int count) {
    final random = math.Random(42);
    final list = <_Particle>[];
    for (int i = 0; i < count; i++) {
      final angle =
          (i / count) * 2 * math.pi + (random.nextDouble() * 0.4 - 0.2);
      final distance = 90.0 + random.nextDouble() * 70.0;
      final size = 1.8 + random.nextDouble() * 2.2;
      final speedFactor = 0.8 + random.nextDouble() * 0.4;
      final color = i % 3 == 0
          ? AppColors.accentCyan
          : (i % 3 == 1 ? AppColors.accentLavender : AppColors.primaryLight);

      list.add(
        _Particle(
          initialAngle: angle,
          initialDistance: distance,
          radius: size,
          speedFactor: speedFactor,
          color: color,
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_mainController, _pulseController]),
      builder: (context, child) {
        final mainVal = _mainController.value;
        final pulseVal = _pulseController.value;

        // Stage progressions
        // Particles: 0.0 -> 0.55
        // Path draw: 0.35 -> 0.80
        // Glow / Settle: 0.65 -> 1.0
        // Wordmark: 0.60 -> 0.95

        final pathProgress = ((mainVal - 0.35) / 0.45).clamp(0.0, 1.0);
        final glowProgress = ((mainVal - 0.60) / 0.40).clamp(0.0, 1.0);
        final wordmarkProgress = ((mainVal - 0.65) / 0.35).clamp(0.0, 1.0);

        final breathingScale = widget.enableBreathing && mainVal >= 0.95
            ? 1.0 + (math.sin(pulseVal * math.pi) * 0.035)
            : 1.0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: breathingScale,
              child: SizedBox(
                width: widget.size * 1.8,
                height: widget.size * 1.8,
                child: CustomPaint(
                  painter: _DynamicLogoPainter(
                    particles: _particles,
                    mainProgress: mainVal,
                    pathProgress: pathProgress,
                    glowProgress: glowProgress,
                    pulseProgress: pulseVal,
                    targetSize: widget.size,
                  ),
                ),
              ),
            ),
            if (widget.showWordmark) ...[
              const SizedBox(height: AppSpacing.lg),
              Opacity(
                opacity: wordmarkProgress,
                child: Transform.translate(
                  offset: Offset(0, 14 * (1.0 - wordmarkProgress)),
                  child: Column(
                    children: [
                      Text(
                        AppStrings.appName,
                        style: AppTypography.display.copyWith(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          foreground: Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFE2E8F0),
                                Color(0xFFCBD5E1),
                              ],
                            ).createShader(const Rect.fromLTWH(0, 0, 200, 40)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        AppStrings.appTagline,
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.accentLavender.withValues(
                            alpha: 0.9,
                          ),
                          letterSpacing: 0.2,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Particle {
  final double initialAngle;
  final double initialDistance;
  final double radius;
  final double speedFactor;
  final Color color;

  _Particle({
    required this.initialAngle,
    required this.initialDistance,
    required this.radius,
    required this.speedFactor,
    required this.color,
  });
}

class _DynamicLogoPainter extends CustomPainter {
  final List<_Particle> particles;
  final double mainProgress;
  final double pathProgress;
  final double glowProgress;
  final double pulseProgress;
  final double targetSize;

  _DynamicLogoPainter({
    required this.particles,
    required this.mainProgress,
    required this.pathProgress,
    required this.glowProgress,
    required this.pulseProgress,
    required this.targetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final logoRadius = targetSize * 0.42;

    // 1. PARTICLES (Convergence phase: 0.0 -> 0.55)
    if (mainProgress < 0.65) {
      for (final p in particles) {
        // As progress moves from 0 to 0.55, distance decreases to 0
        final convergeVal = Curves.easeInOutCubic.transform(
          (mainProgress / 0.55).clamp(0.0, 1.0),
        );

        final currentDistance =
            p.initialDistance * (1.0 - convergeVal * p.speedFactor);
        final currentAngle = p.initialAngle + (convergeVal * math.pi * 0.5);

        final px = center.dx + math.cos(currentAngle) * currentDistance;
        final py = center.dy + math.sin(currentAngle) * currentDistance;

        final particleOpacity = (1.0 - (convergeVal * 0.9)).clamp(0.0, 1.0);
        final pPaint = Paint()
          ..color = p.color.withValues(alpha: particleOpacity * 0.85)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(px, py),
          p.radius * (1.0 - convergeVal * 0.3),
          pPaint,
        );
      }
    }

    // 2. AMBIENT GLOW (Grows as logo forms)
    if (glowProgress > 0.0) {
      final pulseGlow = (math.sin(pulseProgress * math.pi) * 0.15);
      final glowPaint = Paint()
        ..color = AppColors.primaryLight.withValues(
          alpha: ((0.25 + pulseGlow) * glowProgress).clamp(0.0, 0.6),
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24.0);
      canvas.drawCircle(center, logoRadius * 0.95, glowPaint);
    }

    // 3. LOGO CONTAINER RRECT
    if (pathProgress > 0.0) {
      final rect = Rect.fromCenter(
        center: center,
        width: targetSize * 0.82,
        height: targetSize * 0.82,
      );
      final rrect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(targetSize * 0.28),
      );

      // Background fill
      final fillPaint = Paint()
        ..color = AppColors.surfaceElevated.withValues(
          alpha: 0.75 * pathProgress,
        )
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      // Subtle glass border
      final borderPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.3 * pathProgress),
            AppColors.primaryLight.withValues(alpha: 0.2 * pathProgress),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawRRect(rrect, borderPaint);

      // 4. INNER M-PULSE PATH TRACING
      final w = targetSize;
      final h = targetSize;
      final ox = center.dx - w / 2;
      final oy = center.dy - h / 2;

      final p1 = Offset(ox + w * 0.26, oy + h * 0.60);
      final p2 = Offset(ox + w * 0.36, oy + h * 0.38);
      final p3 = Offset(ox + w * 0.50, oy + h * 0.54);
      final p4 = Offset(ox + w * 0.64, oy + h * 0.38);
      final p5 = Offset(ox + w * 0.74, oy + h * 0.60);

      final fullPath = Path()
        ..moveTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..lineTo(p3.dx, p3.dy)
        ..lineTo(p4.dx, p4.dy)
        ..lineTo(p5.dx, p5.dy);

      // Extract progressive trimmed path
      final metrics = fullPath.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final extractLength = metric.length * pathProgress;
        final animatedPath = metric.extractPath(0.0, extractLength);

        final strokeWidth = targetSize * 0.085;
        final strokePaint = Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFC084FC), Color(0xFF7C3AED), Color(0xFF38BDF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawPath(animatedPath, strokePaint);

        // Center sync dot reveal
        if (pathProgress >= 0.55) {
          final dotProgress = ((pathProgress - 0.55) / 0.45).clamp(0.0, 1.0);
          final dotPaint = Paint()
            ..color = AppColors.accentCyan.withValues(alpha: dotProgress)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(p3, strokeWidth * 0.45 * dotProgress, dotPaint);

          final dotGlow = Paint()
            ..color = AppColors.accentCyan.withValues(alpha: 0.6 * dotProgress)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
          canvas.drawCircle(p3, strokeWidth * 0.9 * dotProgress, dotGlow);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DynamicLogoPainter oldDelegate) {
    return oldDelegate.mainProgress != mainProgress ||
        oldDelegate.pulseProgress != pulseProgress;
  }
}
