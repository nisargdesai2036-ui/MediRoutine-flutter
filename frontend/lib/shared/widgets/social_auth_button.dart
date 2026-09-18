import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/animations/app_animations.dart';

enum SocialProvider { google, apple }

/// A clean, minimalist social auth button matching the light surface aesthetic.
class SocialAuthButton extends StatefulWidget {
  final SocialProvider provider;
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.text,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed && _isEnabled ? 0.985 : 1.0;

    return MouseRegion(
      onEnter: (_) {
        if (_isEnabled) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (_isEnabled) setState(() => _isHovered = false);
      },
      child: AnimatedScale(
        scale: scale,
        duration: AppAnimations.instant,
        curve: AppAnimations.easeOut,
        child: Container(
          height: 48.0,
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.socialButtonHover
                : AppColors.socialButtonBg,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(
              color: _isHovered
                  ? AppColors.borderMedium
                  : AppColors.socialButtonBorder,
              width: 1.0,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppSpacing.roundedMd,
              onTap: _isEnabled ? widget.onPressed : null,
              onHighlightChanged: (pressed) {
                if (mounted) setState(() => _isPressed = pressed);
              },
              splashColor: AppColors.primary.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textSecondary,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildProviderIcon(),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              widget.text,
                              style: AppTypography.button.copyWith(
                                color: AppColors.textPrimary,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderIcon() {
    if (widget.provider == SocialProvider.google) {
      return SizedBox(
        width: 18.0,
        height: 18.0,
        child: CustomPaint(painter: _GoogleIconPainter()),
      );
    } else {
      return const Icon(Icons.apple, size: 20.0, color: AppColors.textPrimary);
    }
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    canvas.drawArc(rect, -2.35, 1.5, false, redPaint);
    canvas.drawArc(rect, 2.35, 1.5, false, yellowPaint);
    canvas.drawArc(rect, 0.85, 1.5, false, greenPaint);
    canvas.drawArc(rect, -0.75, 1.5, false, bluePaint);

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx - 1,
          center.dy - strokeWidth / 2,
          radius + 1,
          strokeWidth,
        ),
        const Radius.circular(2.0),
      ),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
