import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../shared/widgets/abstract_routine_visual.dart';
import '../../../shared/widgets/medi_logo.dart';
import 'auth_controller.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// The master responsive split-screen authentication experience for MediRoutine.
/// Renders an editorial split composition on desktop and an adaptive single-column on mobile.
class AuthScreen extends StatefulWidget {
  final bool initialIsLogin;
  final AuthController? controller;

  const AuthScreen({super.key, this.initialIsLogin = true, this.controller});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late bool _isLogin;
  late final AuthController _authController;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.initialIsLogin;
    _authController = widget.controller ?? AuthController();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) {
            return _buildDesktopSplitLayout(constraints);
          } else {
            return _buildMobileLayout(constraints);
          }
        },
      ),
    );
  }

  /// ----------------------------------------------------
  /// DESKTOP / LAPTOP SPLIT COMPOSITION (>= 900px)
  /// ----------------------------------------------------
  Widget _buildDesktopSplitLayout(BoxConstraints constraints) {
    return Row(
      children: [
        // Left Side: Deep Editorial Brand Panel
        Expanded(
          flex: 48,
          child: Container(
            height: double.infinity,
            color: AppColors.brandBackground,
            child: Stack(
              children: [
                // Top-Left Brand Logo & Wordmark
                Positioned(
                  top: AppSpacing.xxxl,
                  left: AppSpacing.xxxl,
                  child: Row(
                    children: [
                      const MediLogo(size: 38.0),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'MediRoutine',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 22.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Center: Generative Abstract Routine Artwork
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    child: AbstractRoutineVisual(size: 340.0),
                  ),
                ),

                // Bottom: Editorial Message & Value Proposition
                Positioned(
                  bottom: AppSpacing.xxxl,
                  left: AppSpacing.xxxl,
                  right: AppSpacing.xxxl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your health, on routine.',
                        style: AppTypography.displayLarge.copyWith(
                          fontSize: 28.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'A personal medication and routine companion designed for clarity, adherence, and peace of mind.',
                        style: AppTypography.brandSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.brandSurfaceElevated,
                          borderRadius: AppSpacing.roundedFull,
                          border: Border.all(
                            color: AppColors.brandBorder,
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              size: 14.0,
                              color: AppColors.brandCyan,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Private, encrypted health data',
                              style: AppTypography.caption.copyWith(
                                color: const Color(0xFFCBD5E1),
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Right Side: Clean, Airy Auth Surface
        Expanded(
          flex: 52,
          child: Container(
            height: double.infinity,
            color: AppColors.surfaceBackground,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.huge,
                  vertical: AppSpacing.xxxl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440.0),
                  child: AnimatedCrossFade(
                    duration: const Duration(milliseconds: 280),
                    crossFadeState: _isLogin
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: LoginForm(
                      controller: _authController,
                      onSwitchToSignUp: _toggleMode,
                      showHeaderLogo: false,
                    ),
                    secondChild: SignUpForm(
                      controller: _authController,
                      onSwitchToLogin: _toggleMode,
                      showHeaderLogo: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// ----------------------------------------------------
  /// MOBILE / COMPACT VIEWPORT (< 900px)
  /// ----------------------------------------------------
  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Column(
              children: [
                // Top Brand Mark on Mobile
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.md,
                      bottom: AppSpacing.xl,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const MediLogo(size: 34.0),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'MediRoutine',
                          style: AppTypography.title.copyWith(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Form Container
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 280),
                  crossFadeState: _isLogin
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: LoginForm(
                    controller: _authController,
                    onSwitchToSignUp: _toggleMode,
                    showHeaderLogo: false,
                  ),
                  secondChild: SignUpForm(
                    controller: _authController,
                    onSwitchToLogin: _toggleMode,
                    showHeaderLogo: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
