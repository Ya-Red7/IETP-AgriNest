import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/phone_index_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late AnimationController _logoController;
  late Animation<double> _logoAnimation;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PhoneIndexService _phoneIndexService = PhoneIndexService();
  bool _isLoading = false;
  String? _errorMessage;

  // Validation methods
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidEthiopianPhone(String phone) {
    // Remove all spaces, dashes, and parentheses for validation
    final cleanedPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Check for +251 prefix and remove it
    String phoneWithoutPrefix = cleanedPhone.startsWith('+251')
        ? cleanedPhone.substring(4)
        : cleanedPhone.startsWith('251')
            ? cleanedPhone.substring(3)
            : cleanedPhone;

    // Remove leading 0 if present (for 0XXXXXXXXX format)
    if (phoneWithoutPrefix.startsWith('0')) {
      phoneWithoutPrefix = phoneWithoutPrefix.substring(1);
    }

    // Ethiopian phone numbers should be 9 digits starting with 9, 7, or 3
    final ethiopianPhoneRegex = RegExp(r'^[973]\d{8}$');
    return ethiopianPhoneRegex.hasMatch(phoneWithoutPrefix);
  }

  String _formatPhoneNumber(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+251')) {
      return cleaned;
    } else if (cleaned.startsWith('251')) {
      return '+${cleaned}';
    } else if (cleaned.startsWith('0')) {
      return '+251${cleaned.substring(1)}';
    } else {
      return '+251$cleaned';
    }
  }

  @override
  void initState() {
    super.initState();

    // Logo scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    // Start logo animation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _logoController.forward();
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppStyles.background(context),
            ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Ethiopian flag stripe
                Container(
                  height: 4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 40),

                // Logo and title
                ScaleTransition(
                  scale: _logoAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer(
                        builder: (context, ref, child) {
                          final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                          return Text(
                            isAmharic ? 'መለያ ይፍጠሩ' : 'Create Account',
                            style: TextStyle(
                              color: AppStyles.textPrimary(context),
                              fontSize: isAmharic ? 24 : 28,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Signup form
                Column(
                  children: [
                    // Full Name
                    _buildTextField(
                      context,
                      controller: _fullNameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person,
                    ),

                    const SizedBox(height: 16),

                    // Email
                    _buildTextField(
                      context,
                      controller: _emailController,
                      label: 'Email',
                      hint: 'your.email@example.com',
                      icon: Icons.mail,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(
                      context,
                      controller: _phoneController,
                      label: 'Phone Number',
                      hint: '+251 9XX XXX XXX, 09XX XXX XXX, or 2519XX...',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 16),

                    // Password
                    _buildTextField(
                      context,
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a strong password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),

                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildTextField(
                      context,
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),

                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Signup button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryGreen,
                            AppColors.primaryGreen.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          await _handleSignup(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Consumer(
                              builder: (context, ref, child) {
                                final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                return Text(
                                  isAmharic ? 'ይመዝገቡ' : 'Sign Up',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                );
                              },
                            ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppStyles.textSecondary(context),
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.go(AppConstants.loginRoute);
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.primaryGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Footer
                    Text(
                      'Group 81 – AASTU 2025',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
        );
      },
    );
  }

  Future<void> _handleSignup(BuildContext context) async {
    // Reset error message
    setState(() {
      _errorMessage = null;
    });

    // Basic validation
    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields';
      });
      return;
    }

    // Email validation
    if (!_isValidEmail(_emailController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    // Phone validation
    if (!_isValidEthiopianPhone(_phoneController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid Ethiopian phone number (e.g., +251 9XX XXX XXX, 09XX XXX XXX, or 2519XX...)';
      });
      return;
    }

    // Password validation
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());
      final name = _fullNameController.text.trim();

      // 1️⃣ Check phone availability (PUBLIC - unauthenticated)
      final phoneTaken = await _phoneIndexService.isPhoneTaken(formattedPhone);
      if (phoneTaken) {
        setState(() {
          _errorMessage = 'Phone number already registered. Please use a different number.';
        });
        return;
      }

      // 2️⃣ Create Firebase Auth user
      final user = await _authService.register(
        email: email,
        password: password,
      );

      if (user == null) {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
        return;
      }

      // 3️⃣ Create user profile in Firestore
      await _userService.createUserProfile(
        uid: user.uid,
        name: name,
        phone: formattedPhone,
        email: email,
      );

      // 4️⃣ Reserve phone number (AUTHENTICATED)
      await _phoneIndexService.reservePhone(formattedPhone);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen
        context.go(AppConstants.homeRoute);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.textFieldLabel(context),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: AppStyles.textFieldDecoration(context),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              color: AppStyles.textPrimary(context),
              fontSize: 16,
            ),
            decoration: AppStyles.textFieldInputDecoration(context, hint, icon),
          ),
        ),
      ],
    );
  }
}
