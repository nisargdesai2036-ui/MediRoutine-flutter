import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/animations/page_transitions.dart';
import '../../../shared/widgets/animated_medi_logo.dart';
import 'auth_screen.dart';

/// Screen 1: Splash / Brand Introduction.
/// Features the dynamic particle convergence, vector glyph tracing,
/// and smooth transition into the master AuthScreen.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _hasNavigated = false;

  void _navigateToAuth() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(
      context,
    ).pushReplacement(MediPageRoute(page: const AuthScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBackground,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background ambient aura
          Positioned(
            top: -100,
            right: -80,
            child: IgnorePointer(
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.brandPrimary.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Top right Skip button
          Positioned(
            top: AppSpacing.xxl,
            right: AppSpacing.xl,
            child: TextButton(
              onPressed: _navigateToAuth,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
              ),
              child: Text(
                AppStrings.skipIntro,
                style: AppTypography.caption.copyWith(
                  color: const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Central Dynamic Brand Logo Animation
          Center(
            child: GestureDetector(
              onTap: _navigateToAuth,
              child: AnimatedMediLogo(
                size: 100.0,
                showWordmark: true,
                onCompleted: () {
                  Future.delayed(
                    const Duration(milliseconds: 450),
                    _navigateToAuth,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
