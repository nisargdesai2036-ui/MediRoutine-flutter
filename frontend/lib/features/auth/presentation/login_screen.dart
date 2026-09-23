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
import 'auth_controller.dart';

/// The Login form component featuring email/password, remember me,
/// forgot password modal, and social auth.
class LoginForm extends StatefulWidget {
  final AuthController controller;
  final VoidCallback? onSwitchToSignUp;
  final bool showHeaderLogo;

  const LoginForm({
    super.key,
    required this.controller,
    this.onSwitchToSignUp,
    this.showHeaderLogo = false,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String? _emailError;
  String? _passwordError;
  bool _rememberMe = false;
  bool _isResetLoading = false;

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
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  bool _validateForm() {
    final emailErr = Validators.validateEmail(_emailController.text);
    final passErr = Validators.validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) return;

    final success = await widget.controller.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      StatusFeedback.show(
        context,
        message:
            '${AppStrings.loginSuccess} ${widget.controller.user?.name ?? ''}'
                .trim(),
        type: FeedbackType.success,
      );
    } else {
      StatusFeedback.show(
        context,
        message:
            widget.controller.errorMessage ??
            'Login failed. Please check your credentials.',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await widget.controller.loginWithGoogle();
    if (!mounted) return;

    if (success) {
      StatusFeedback.show(
        context,
        message: 'Signed in with Google as ',
        type: FeedbackType.success,
      );
    }
  }

  Future<void> _handleAppleLogin() async {
    final success = await widget.controller.loginWithApple();
    if (!mounted) return;

    if (success) {
      StatusFeedback.show(
        context,
        message: 'Signed in with Apple ID',
        type: FeedbackType.success,
      );
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(
      text: _emailController.text,
    );
    String? resetError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              top: AppSpacing.xxl,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xxl,
            ),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusXl),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 24.0,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderMedium,
                      borderRadius: AppSpacing.roundedFull,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  AppStrings.forgotPasswordTitle,
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppStrings.forgotPasswordDescription,
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xl),
                MediTextField(
                  label: AppStrings.emailLabel,
                  hint: AppStrings.emailHint,
                  controller: resetEmailController,
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  errorText: resetError,
                  onChanged: (_) {
                    if (resetError != null) {
                      setSheetState(() => resetError = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
                MediButton(
                  text: AppStrings.sendResetLink,
                  isLoading: _isResetLoading,
                  onPressed: () async {
                    final err = Validators.validateEmail(
                      resetEmailController.text,
                    );
                    if (err != null) {
                      setSheetState(() => resetError = err);
                      return;
                    }
                    setSheetState(() => _isResetLoading = true);
                    final ok = await widget.controller.sendPasswordReset(
                      resetEmailController.text,
                    );
                    setSheetState(() => _isResetLoading = false);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      StatusFeedback.show(
                        context,
                        message: ok
                            ? AppStrings.resetSentSuccess
                            : (widget.controller.errorMessage ??
                                  'Could not send reset email'),
                        type: ok ? FeedbackType.success : FeedbackType.error,
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        AuthHeader(
          title: AppStrings.loginTitle,
          subtitle: AppStrings.loginSubtitle,
          showLogo: widget.showHeaderLogo,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Social Auth Buttons (Placed conveniently at top or bottom)
        SocialAuthButton(
          provider: SocialProvider.google,
          text: AppStrings.continueWithGoogle,
          isLoading: widget.controller.isLoading,
          onPressed: _handleGoogleLogin,
        ),

        const SizedBox(height: AppSpacing.sm),

        SocialAuthButton(
          provider: SocialProvider.apple,
          text: AppStrings.continueWithApple,
          isLoading: widget.controller.isLoading,
          onPressed: _handleAppleLogin,
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
            if (_emailError != null) {
              setState(() => _emailError = null);
            }
          },
          onSubmitted: (_) => _passwordFocus.requestFocus(),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Password Field
        MediTextField(
          label: AppStrings.passwordLabel,
          hint: AppStrings.passwordHint,
          controller: _passwordController,
          focusNode: _passwordFocus,
          isPassword: true,
          prefixIcon: Icons.lock_outline_rounded,
          textInputAction: TextInputAction.done,
          errorText: _passwordError,
          onChanged: (_) {
            if (_passwordError != null) {
              setState(() => _passwordError = null);
            }
          },
          onSubmitted: (_) => _handleLogin(),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Remember Me & Forgot Password Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _rememberMe,
                    onChanged: (val) =>
                        setState(() => _rememberMe = val ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    side: const BorderSide(
                      color: AppColors.borderMedium,
                      width: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: () => setState(() => _rememberMe = !_rememberMe),
                  child: Text(
                    'Remember me',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: _showForgotPasswordDialog,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
              child: Text(
                AppStrings.forgotPassword,
                style: AppTypography.link.copyWith(fontSize: 13.0),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xl),

        // Primary Login Button
        MediButton(
          text: AppStrings.loginButton,
          isLoading: widget.controller.isLoading,
          onPressed: _handleLogin,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Bottom Sign-up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppStrings.dontHaveAccount,
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            GestureDetector(
              onTap: widget.onSwitchToSignUp,
              child: Text(AppStrings.signUpLink, style: AppTypography.link),
            ),
          ],
        ),
      ],
    );
  }
}

/// Standalone page route wrapper for LoginForm
class LoginScreen extends StatelessWidget {
  final AuthController? controller;

  const LoginScreen({super.key, this.controller});

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
              child: LoginForm(controller: ctrl, showHeaderLogo: true),
            ),
          ),
        ),
      ),
    );
  }
}
