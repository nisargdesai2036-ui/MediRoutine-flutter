import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum FeedbackType { error, success, info }

/// Utility to display non-intrusive, styled floating notifications.
class StatusFeedback {
  StatusFeedback._();

  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();

    Color bgColor;
    Color borderColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case FeedbackType.error:
        bgColor = AppColors.surfaceElevated;
        borderColor = AppColors.error;
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        break;
      case FeedbackType.success:
        bgColor = AppColors.surfaceElevated;
        borderColor = AppColors.success;
        icon = Icons.check_circle_outline_rounded;
        iconColor = AppColors.success;
        break;
      case FeedbackType.info:
        bgColor = AppColors.surfaceElevated;
        borderColor = AppColors.primaryLight;
        icon = Icons.info_outline_rounded;
        iconColor = AppColors.accentLavender;
        break;
    }

    final snackBar = SnackBar(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      duration: duration,
      margin: const EdgeInsets.all(AppSpacing.lg),
      behavior: SnackBarBehavior.floating,
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppSpacing.roundedMd,
          border: Border.all(
            color: borderColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.15),
              blurRadius: 16.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.0, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    scaffoldMessenger.showSnackBar(snackBar);
  }
}
