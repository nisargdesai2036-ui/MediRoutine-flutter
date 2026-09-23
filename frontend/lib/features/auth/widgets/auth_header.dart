import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/medi_logo.dart';

/// Reusable auth screen header with title, subtitle, and optional compact logo.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final double logoSize;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = false,
    this.logoSize = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLogo) ...[
          MediLogo(size: logoSize),
          const SizedBox(height: AppSpacing.lg),
        ],
        Text(title, style: AppTypography.displayHeadline),
        const SizedBox(height: AppSpacing.xs),
        Text(subtitle, style: AppTypography.subtitle),
      ],
    );
  }
}
