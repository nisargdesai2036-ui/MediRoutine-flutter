import 'package:flutter/material.dart';
import 'package:frontend/Sessions/UserSession.dart';
import '../coreapi/ApiService.dart';
import 'client_dashboard.dart';

class ProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const ProfilePage({
    super.key,
    this.name = '',
    this.email = '',
    this.password = '',
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryBlue = Color(0xFF0077B6);
  static const Color darkText = Color(0xFF1E293B);
  static const Color secondaryText = Color(0xFF64748B);
  static const Color backgroundColor = Color(0xFFF4F7FB);

  @override
  void initState() {
    super.initState();

    // Existing database/session values are displayed
    // inside the editable fields.
    _nameController = TextEditingController(text: widget.name);

    _emailController = TextEditingController(text: widget.email);

    _passwordController = TextEditingController(text: widget.password);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  // ----------------------------------------------------------
  // BACK
  // ----------------------------------------------------------

  void _handleBack() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDashboard(
          userId: UserSession.userid,
          clientName: widget.name.isNotEmpty ? widget.name : 'Client',
          clientAge: 25,
          clientEmail: widget.email,
          clientPassword: widget.password,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // SAVE
  // ----------------------------------------------------------

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final userId = UserSession.userid;

    if (userId == null) {
      _showMessage(
        'User session not found. Please login again.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final updatedName = _nameController.text.trim();
    final updatedEmail = _emailController.text.trim();
    final updatedPassword = _passwordController.text;

    final patchData = {
      'name': updatedName,
      'email': updatedEmail,
      'password': updatedPassword,
    };

    try {
      await ApiService.patch("/api/users/update/$userId", patchData);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Profile updated successfully!');

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => ClientDashboard(
            userId: UserSession.userid,
            clientName: updatedName.isNotEmpty ? updatedName : 'Client',
            clientAge: 25,
            clientEmail: updatedEmail,
            clientPassword: updatedPassword,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage(
        'Unable to update profile. Please try again.',
        isError: true,
      );
    }
  }

  // ----------------------------------------------------------
  // MESSAGE
  // ----------------------------------------------------------

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? Colors.redAccent : primaryBlue,
      ),
    );
  }

  // ----------------------------------------------------------
  // FORM FIELD
  // ----------------------------------------------------------

  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkText,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,

          keyboardType: keyboardType,

          obscureText: isPassword ? _obscurePassword : false,

          validator: validator,

          style: const TextStyle(fontSize: 15, color: darkText),

          decoration: InputDecoration(
            hintText: hint,

            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),

            prefixIcon: Icon(icon, color: secondaryText, size: 20),

            // Password eye button
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: secondaryText,
                      size: 20,
                    ),
                  )
                : null,

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ======================================================
      // APP BAR
      // ======================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkText),
          onPressed: _handleBack,
        ),

        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: darkText,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ======================================================
      // BODY
      // ======================================================
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==================================================
                // PROFILE HEADER
                // ==================================================
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,

                        decoration: BoxDecoration(
                          color: primaryBlue,
                          shape: BoxShape.circle,

                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withValues(alpha: 0.20),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),

                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Edit your profile',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Update your account information',
                        style: TextStyle(fontSize: 14, color: secondaryText),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ==================================================
                // FORM CARD
                // ==================================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(14),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: darkText,
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        'Update your name, email and password.',
                        style: TextStyle(fontSize: 13, color: secondaryText),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // NAME
                      // ==================================================
                      _buildFormField(
                        label: 'Name',
                        hint: 'Enter your name',
                        controller: _nameController,
                        icon: Icons.person_outline,

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // EMAIL
                      // ==================================================
                      _buildFormField(
                        label: 'Email',
                        hint: 'Enter your email',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,

                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }

                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );

                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Please enter a valid email';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // ==================================================
                      // PASSWORD
                      // ==================================================
                      _buildFormField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        icon: Icons.lock_outline,
                        isPassword: true,

                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }

                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      const Divider(color: Color(0xFFE2E8F0)),

                      const SizedBox(height: 22),

                      // ==================================================
                      // BUTTONS
                      // ==================================================
                      Row(
                        children: [
                          // CANCEL
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _handleBack,

                              style: OutlinedButton.styleFrom(
                                foregroundColor: darkText,

                                side: const BorderSide(
                                  color: Color(0xFFCBD5E1),
                                ),

                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),

                              child: const Text(
                                'Cancel',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // SAVE
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSave,

                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,

                                foregroundColor: Colors.white,

                                elevation: 0,

                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),

                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),

                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,

                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // PASSWORD INFORMATION
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),

                    borderRadius: BorderRadius.circular(8),

                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: primaryBlue,
                        size: 20,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Your password is hidden for security. '
                          'Tap the eye icon if you want to view it.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
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
