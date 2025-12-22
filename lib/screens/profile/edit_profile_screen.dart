import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/language_provider.dart';
import '../../services/user_service.dart';
import '../../services/phone_index_service.dart';
import '../../models/app_user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final UserService _userService = UserService();
  final PhoneIndexService _phoneIndexService = PhoneIndexService();

  bool _isLoading = false;
  bool _isLoadingProfile = true;
  AppUser? _currentUser;
  String? _errorMessage;

  // Validation methods
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
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      try {
        final user = await _userService.getUserProfile(uid);
        if (user != null) {
          setState(() {
            _currentUser = user;
            _nameController.text = user.name;
            _phoneController.text = user.phone;
            _isLoadingProfile = false;
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load profile: $e';
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields';
      });
      return;
    }

    // Phone validation
    if (!_isValidEthiopianPhone(_phoneController.text.trim())) {
      setState(() {
        _errorMessage = 'Please enter a valid Ethiopian phone number';
      });
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format phone number and check if it's already taken by another user
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());

      // Check if phone number has changed
      final currentPhone = _currentUser?.phone;
      if (formattedPhone != currentPhone) {
        // Phone number changed, check availability
        final phoneTaken = await _phoneIndexService.isPhoneTaken(formattedPhone);

        if (phoneTaken) {
          setState(() {
            _errorMessage = 'Phone number already in use by another user';
          });
          return;
        }

        // If phone changed and is available, reserve the new one
        await _phoneIndexService.reservePhone(formattedPhone);

        // Release the old phone number
        if (currentPhone != null) {
          await _phoneIndexService.releasePhone(currentPhone);
        }
      }

      await _userService.updateUserProfile(
        uid: uid,
        name: _nameController.text.trim(),
        phone: formattedPhone,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
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

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isAmharic = ref.watch(languageProvider).languageCode == 'am';

        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppStyles.background(context),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.go(AppConstants.homeRoute),
                          icon: Icon(
                            Icons.arrow_back,
                            color: AppStyles.textPrimary(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          isAmharic ? 'መለያ አርትዕ' : 'Edit Profile',
                          style: TextStyle(
                            color: AppStyles.textPrimary(context),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

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

                    // Profile icon
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    if (_isLoadingProfile)
                      const Center(child: CircularProgressIndicator())
                    else if (_errorMessage != null && _currentUser == null)
                      Center(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Column(
                        children: [
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

                          // Name field
                          _buildTextField(
                            context,
                            controller: _nameController,
                            label: isAmharic ? 'ሙሉ ስም' : 'Full Name',
                            hint: isAmharic ? 'ሙሉ ስምዎን ያስገቡ' : 'Enter your full name',
                            icon: Icons.person,
                          ),

                          const SizedBox(height: 16),

                          // Phone field
                          _buildTextField(
                            context,
                            controller: _phoneController,
                            label: isAmharic ? 'ስልክ ቁጥር' : 'Phone Number',
                            hint: isAmharic ? '+251 9XX XXX XXX, 09XX XXX XXX, ወይም 2519XX...' : '+251 9XX XXX XXX, 09XX XXX XXX, or 2519XX...',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 8),

                          // Email (read-only)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.glassBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppStyles.border(context),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: AppStyles.textMuted(context),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAmharic ? 'ኢሜይል' : 'Email',
                                        style: TextStyle(
                                          color: AppStyles.textSecondary(context),
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        _currentUser?.email ?? '',
                                        style: TextStyle(
                                          color: AppStyles.textPrimary(context),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Update button
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
                              onPressed: _isLoading ? null : _updateProfile,
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
                                : Text(
                                    isAmharic ? 'አርትዕ' : 'Update Profile',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppStyles.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: AppStyles.textFieldDecoration(context),
          child: TextField(
            controller: controller,
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
