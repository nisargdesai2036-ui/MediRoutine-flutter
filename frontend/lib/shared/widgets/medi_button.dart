import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/animations/app_animations.dart';

enum MediButtonVariant { primary, secondary, outline, text }

/// A tactile, modern button with hover elevation, subtle press scale, and loading state.
class MediButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final double height;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final MediButtonVariant variant;

  const MediButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height = 50.0,
    this.leadingIcon,
    this.trailingIcon,
    this.variant = MediButtonVariant.primary,
  });

  @override
  State<MediButton> createState() => _MediButtonState();
}

class _MediButtonState extends State<MediButton> {
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
        child: SizedBox(
          width: widget.isFullWidth ? double.infinity : null,
          height: widget.height,
          child: _buildButtonBody(),
        ),
      ),
    );
  }

  Widget _buildButtonBody() {
    switch (widget.variant) {
      case MediButtonVariant.primary:
        return _buildPrimaryButton();
      case MediButtonVariant.secondary:
        return _buildSecondaryButton();
      case MediButtonVariant.outline:
        return _buildOutlineButton();
      case MediButtonVariant.text:
        return _buildTextButton();
    }
  }

  Widget _buildPrimaryButton() {
    final bgColor = !_isEnabled
        ? AppColors.primary.withValues(alpha: 0.45)
        : (_isHovered ? AppColors.primaryHover : AppColors.primary);

    return AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedMd,
        boxShadow: _isEnabled
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: _isHovered ? 0.28 : 0.18,
                  ),
                  blurRadius: _isHovered ? 14.0 : 8.0,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedMd,
          onTap: _isEnabled ? widget.onPressed : null,
          onHighlightChanged: (pressed) {
            if (mounted) setState(() => _isPressed = pressed);
          },
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : _buildContent(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return Container(
      decoration: BoxDecoration(
        color: _isHovered ? AppColors.surfaceElevated : AppColors.surfaceCard,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.roundedMd,
          onTap: _isEnabled ? widget.onPressed : null,
          onHighlightChanged: (pressed) {
            if (mounted) setState(() => _isPressed = pressed);
          },
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textPrimary,
                      ),
                    ),
                  )
                : _buildContent(AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: AppSpacing.roundedMd,
        border: Border.all(
          color: _isEnabled ? AppColors.primary : AppColors.borderSubtle,
          width: 1.2,
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
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  )
                : _buildContent(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: _isEnabled ? widget.onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      ),
      child: widget.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : Text(widget.text, style: AppTypography.link),
    );
  }

  Widget _buildContent(Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leadingIcon != null) ...[
          widget.leadingIcon!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.text,
          style: AppTypography.button.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          widget.trailingIcon!,
        ],
      ],
    );
  }
}
