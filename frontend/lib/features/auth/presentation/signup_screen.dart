import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/medi_button.dart';
import '../../../shared/widgets/medi_text_field.dart';
import '../../../shared/widgets/social_auth_button.dart';
import '../../../shared/widgets/status_feedback.dart';
import '../widgets/auth_header.dart';
import '../widgets/trust_badge.dart';
import 'auth_controller.dart';

/// The Sign Up form component with name, email, password strength meter,
/// confirm password match, trust badge, and social sign-up.
class SignUpForm extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onSwitchToLogin;
  final bool showHeaderLogo;

  const SignUpForm({
    super.key,
    required this.controller,
    this.onSwitchToLogin,
    this.showHeaderLogo = false,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  int _passwordStrength = 0; // 0 = empty, 1 = weak, 2 = medium, 3 = strong
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onAuthStateChanged);
  }

  void _onAuthStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAuthStateChanged);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _evaluatePasswordStrength(String pass) {
    int strength = 0;
    if (pass.isNotEmpty) strength = 1;
    if (pass.length >= 8 && RegExp(r'[0-9]').hasMatch(pass)) strength = 2;
    if (pass.length >= 10 &&
        RegExp(r'[0-9]').hasMatch(pass) &&
        RegExp(r'[!@#$%^&*()_+]').hasMatch(pass)) {
      strength = 3;
    }

    final match =
        _confirmPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text == pass;

    setState(() {
      _passwordStrength = strength;
      _passwordsMatch = match;
    });
  }

  void _checkPasswordMatch(String confirm) {
    setState(() {
      _passwordsMatch =
          confirm.isNotEmpty && confirm == _passwordController.text;
    });
  }

  bool _validateForm() {
    final nameErr = Validators.validateName(_nameController.text);
    final emailErr = Validators.validateEmail(_emailController.text);
    final passErr = Validators.validatePassword(_passwordController.text);
    final confirmErr = Validators.validateConfirmPassword(
      _confirmPasswordController.text,
      _passwordController.text,
    );

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmPasswordError = confirmErr;
    });

    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) return;

    final success = await widget.controller.signUp(
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      StatusFeedback.show(
        context,
        message: AppStrings.signUpSuccess,
        type: FeedbackType.success,
      );
    } else {
      StatusFeedback.show(
        context,
        message:
            widget.controller.errorMessage ??
            'Registration failed. Please try again.',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final success = await widget.controller.loginWithGoogle();
    if (!mounted) return;

    if (success) {
      StatusFeedback.show(
        context,
        message: 'Account created with Google!',
        type: FeedbackType.success,
      );
    }
  }

  Future<void> _handleAppleSignUp() async {
    final success = await widget.controller.loginWithApple();
    if (!mounted) return;

    if (success) {
      StatusFeedback.show(
        context,
        message: 'Account created with Apple ID!',
        type: FeedbackType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        AuthHeader(
          title: AppStrings.signUpTitle,
          subtitle: AppStrings.signUpSubtitle,
          showLogo: widget.showHeaderLogo,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Social Sign-up Buttons
        SocialAuthButton(
          provider: SocialProvider.google,
          text: AppStrings.signUpWithGoogle,
          isLoading: widget.controller.isLoading,
          onPressed: _handleGoogleSignUp,
        ),

        const SizedBox(height: AppSpacing.sm),

        SocialAuthButton(
          provider: SocialProvider.apple,
          text: AppStrings.signUpWithApple,
          isLoading: widget.controller.isLoading,
          onPressed: _handleAppleSignUp,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Divider
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text(AppStrings.orDivider, style: AppTypography.caption),
            ),
            const Expanded(child: Divider()),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Full Name Field
        MediTextField(
          label: AppStrings.nameLabel,
          hint: AppStrings.nameHint,
          controller: _nameController,
          focusNode: _nameFocus,
          prefixIcon: Icons.person_outline_rounded,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          errorText: _nameError,
          onChanged: (_) {
            if (_nameError != null) setState(() => _nameError = null);
          },
          onSubmitted: (_) => _emailFocus.requestFocus(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Email Field
        MediTextField(
          label: AppStrings.emailLabel,
          hint: AppStrings.emailHint,
          controller: _emailController,
          focusNode: _emailFocus,
          prefixIcon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: _emailError,
          onChanged: (_) {
            if (_emailError != null) setState(() => _emailError = null);
          },
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Password Field
        MediTextField(
          label: AppStrings.passwordLabel,
          hint: AppStrings.createPasswordHint,
          controller: _passwordController,
          focusNode: _passwordFocus,
          isPassword: true,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: TextInputAction.next,
          errorText: _passwordError,
          onChanged: (val) {
            if (_passwordError != null) setState(() => _passwordError = null);
            _evaluatePasswordStrength(val);
          },
          onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
        ),

        // Animated Password Strength Meter
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              for (int i = 1; i <= 3; i++) ...[
                Expanded(
                  child: Container(
                    height: 3.5,
                    margin: const EdgeInsets.only(right: 4.0),
                    decoration: BoxDecoration(
                      color: i <= _passwordStrength
                          ? (_passwordStrength == 1
                                ? AppColors.warning
                                : (_passwordStrength == 2
                                      ? AppColors.brandIndigo
                                      : AppColors.success))
                          : AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ],
              Text(
                _passwordStrength == 1
                    ? 'Weak'
                    : (_passwordStrength == 2 ? 'Good' : 'Strong'),
                style: AppTypography.caption.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: _passwordStrength == 1
                      ? AppColors.warning
                      : (_passwordStrength == 2
                            ? AppColors.brandIndigo
                            : AppColors.success),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Confirm Password Field
        MediTextField(
          label: AppStrings.confirmPasswordLabel,
          hint: AppStrings.confirmPasswordHint,
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          isPassword: true,
          prefixIcon: Icons.lock_reset_rounded,
          textInputAction: TextInputAction.done,
          errorText: _confirmPasswordError,
          onChanged: (val) {
            if (_confirmPasswordError != null) {
              setState(() => _confirmPasswordError = null);
            }
            _checkPasswordMatch(val);
          },
          onSubmitted: (_) => _handleSignUp(),
        ),

        if (_passwordsMatch) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, top: 4.0),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 13.0,
                  color: AppColors.success,
                ),
                const SizedBox(width: 4.0),
                Text(
                  'Passwords match',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Privacy & Trust Badge
        const TrustBadge(),

        const SizedBox(height: AppSpacing.xl),

        // Create Account CTA Button
        MediButton(
          text: AppStrings.signUpButton,
          isLoading: widget.controller.isLoading,
          onPressed: _handleSignUp,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Bottom Navigation Link to Login
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.alreadyHaveAccount,
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: widget.onSwitchToLogin,
              child: Text(AppStrings.loginLink, style: AppTypography.link),
            ),
          ],
        ),
      ],
    );
  }
}

/// Standalone page route wrapper for SignUpForm
class SignUpScreen extends StatelessWidget {
  final AuthController? controller;

  const SignUpScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final ctrl = controller ?? AuthController();
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: AppSpacing.paddingScreen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppSpacing.maxContentWidth,
              ),
              child: SignUpForm(controller: ctrl, showHeaderLogo: true),
            ),
          ),
        ),
      ),
    );
  }
}
