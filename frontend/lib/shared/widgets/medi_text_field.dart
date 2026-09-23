import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/animations/app_animations.dart';

/// A refined, minimalist input field with subtle focus glow, clean label,
/// leading icon, clear button, and password visibility toggle.
class MediTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? errorText;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool enabled;

  const MediTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.autofocus = false,
    this.enabled = true,
  });

  @override
  State<MediTextField> createState() => _MediTextFieldState();
}

class _MediTextFieldState extends State<MediTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = true;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _obscureText = widget.isPassword;

    widget.controller?.addListener(_handleTextChange);
    _hasText = widget.controller?.text.isNotEmpty ?? false;
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _handleTextChange() {
    final has = widget.controller?.text.isNotEmpty ?? false;
    if (has != _hasText && mounted) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    widget.controller?.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    final borderColor = hasError
        ? AppColors.error
        : (_isFocused ? AppColors.borderFocus : AppColors.borderSubtle);

    final fillColor = _isFocused ? Colors.white : AppColors.surfaceInput;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 2.0, bottom: 7.0),
          child: Text(
            widget.label,
            style: AppTypography.label.copyWith(
              color: hasError
                  ? AppColors.error
                  : (_isFocused ? AppColors.primary : AppColors.textSecondary),
            ),
          ),
        ),

        // Input Box Container
        AnimatedContainer(
          duration: AppAnimations.fast,
          curve: AppAnimations.easeOut,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: AppSpacing.roundedMd,
            border: Border.all(
              color: borderColor,
              width: _isFocused || hasError ? 1.5 : 1.0,
            ),
            boxShadow: [
              if (_isFocused && !hasError)
                BoxShadow(
                  color: AppColors.borderFocusGlow,
                  blurRadius: 8.0,
                  offset: const Offset(0, 1),
                ),
              if (hasError)
                BoxShadow(
                  color: AppColors.error.withValues(alpha: 0.15),
                  blurRadius: 8.0,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled,
            obscureText: widget.isPassword ? _obscureText : false,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: AppTypography.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            cursorColor: AppColors.primary,
            cursorRadius: const Radius.circular(2.0),
            decoration: InputDecoration(
              isDense: true,
              hintText: widget.hint,
              hintStyle: AppTypography.bodySecondary.copyWith(
                color: AppColors.textMuted,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 19.0,
                      color: hasError
                          ? AppColors.error
                          : (_isFocused
                                ? AppColors.primary
                                : AppColors.textMuted),
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 15.0,
              ),
            ),
          ),
        ),

        // Animated Inline Error Message
        AnimatedCrossFade(
          duration: AppAnimations.fast,
          crossFadeState: hasError
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 6.0),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14.0,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4.0),
                Expanded(
                  child: Text(
                    widget.errorText ?? '',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          secondChild: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          size: 19.0,
          color: AppColors.textMuted,
        ),
        onPressed: () {
          setState(() => _obscureText = !_obscureText);
        },
        splashRadius: 18.0,
      );
    }

    if (_hasText && _isFocused) {
      return IconButton(
        icon: const Icon(
          Icons.close_rounded,
          size: 17.0,
          color: AppColors.textMuted,
        ),
        onPressed: () {
          widget.controller?.clear();
          widget.onChanged?.call('');
        },
        splashRadius: 18.0,
      );
    }

    return null;
  }
}
