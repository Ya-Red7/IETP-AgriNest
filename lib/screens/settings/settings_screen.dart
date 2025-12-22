import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _switchController;
  bool _soilMoistureAlerts = true;
  bool _temperatureWarnings = true;
  bool _dailyReports = false;

  @override
  void initState() {
    super.initState();
    _switchController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.homeRoute);
        break;
      case 1:
        context.go(AppConstants.analyticsRoute);
        break;
      case 2:
        // Already on settings
        break;
    }
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
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            ),
        child: Stack(
          children: [
            // Ethiopian flag stripe at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:                 Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                  ),
                ),
            ),

            // Header
            Positioned(
              top: 4,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface.withOpacity(0.8) : AppColors.surface.withOpacity(0.8),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        return Text(
                          isAmharic ? 'ቅንብሮች' : 'Settings',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: isAmharic ? 20 : 24,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Scrollable content
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              bottom: 0,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Dark/Light mode toggle
                    _buildSettingCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
                              return Icon(
                                isDark ? Icons.dark_mode : Icons.light_mode,
                                color: AppStyles.textPrimary(context),
                                size: 24,
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isAmharic ? 'ጨለማ ሁነታ' : 'Dark Mode',
                                          style: TextStyle(
                                            color: AppStyles.textPrimary(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final themeMode = ref.watch(themeModeProvider);
                              final isDark = themeMode == ThemeMode.dark;

                              return InkWell(
                                onTap: () {
                                  ref.read(themeModeProvider.notifier).toggleTheme();
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  width: 56,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isDark ? AppColors.primaryGreen : Colors.grey[600],
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      margin: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Language toggle
                    _buildSettingCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Text(
                            'Language',
                            style: TextStyle(
                              color: AppStyles.textPrimary(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          Consumer(
                            builder: (context, ref, child) {
                              final isAmharic = ref.watch(languageProvider).languageCode == 'am';

                              return Material(
                                color: isAmharic
                                    ? AppColors.primaryGreenDark
                                    : AppColors.primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: () {
                                    ref.read(languageProvider.notifier).toggleLanguage();
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Text(
                                      isAmharic ? 'አማርኛ' : 'English',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Export CSV button
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                          final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

                          return ElevatedButton(
                            onPressed: () {
                              // TODO: Implement CSV export
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('CSV export functionality coming soon!'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.download,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    isAmharic ? 'መረጃ ወደ CSV ላክ' : 'Export Data as CSV',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Notifications
                    _buildSettingCard(
                      isDark: isDark,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer(
                            builder: (context, ref, child) {
                              final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                              return Text(
                                isAmharic ? 'ማሳወቂያዎች' : 'Notifications',
                                style: TextStyle(
                                  color: AppStyles.textPrimary(context),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Consumer(
                            builder: (context, ref, child) {
                              final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                              return Column(
                                children: [
                                  _buildNotificationToggle(
                                    isAmharic ? 'ያሉበት አፈር እርጥበት ማሳወቂያ' : 'Low soil moisture alerts',
                                    '',
                                    _soilMoistureAlerts,
                                    (value) => setState(() => _soilMoistureAlerts = value),
                                  ),
                                  _buildNotificationToggle(
                                    isAmharic ? 'የሙቀት ማስጠንቀቂያ' : 'Temperature warnings',
                                    '',
                                    _temperatureWarnings,
                                    (value) => setState(() => _temperatureWarnings = value),
                                  ),
                                  _buildNotificationToggle(
                                    isAmharic ? 'ዕለታዊ ሪፖርት' : 'Daily reports',
                                    '',
                                    _dailyReports,
                                    (value) => setState(() => _dailyReports = value),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Profile section
                    _buildSettingCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                return Text(
                                  isAmharic ? 'መለያ አርትዕ' : 'Edit Profile',
                                  style: TextStyle(
                                    color: AppStyles.textPrimary(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context.go(AppConstants.editProfileRoute);
                            },
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: AppStyles.textSecondary(context),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Logout section
                    _buildSettingCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer(
                              builder: (context, ref, child) {
                                final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                return Text(
                                  isAmharic ? 'ውጣ' : 'Logout',
                                  style: TextStyle(
                                    color: AppStyles.textPrimary(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Show confirmation dialog
                              final shouldLogout = await showDialog<bool>(
                                context: context,
                                builder: (context) => Consumer(
                                  builder: (context, ref, child) {
                                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                    return AlertDialog(
                                      backgroundColor: AppStyles.card(context),
                                      title: Text(
                                        isAmharic ? 'እርግጠኛ ነህ?' : 'Are you sure?',
                                        style: TextStyle(color: AppStyles.textPrimary(context)),
                                      ),
                                      content: Text(
                                        isAmharic ? 'ከመለያዎ መውጣት ይፈልጋሉ?' : 'Do you want to logout?',
                                        style: TextStyle(color: AppStyles.textSecondary(context)),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(
                                            isAmharic ? 'ራስ አልበልጥም' : 'Cancel',
                                            style: TextStyle(color: AppStyles.textSecondary(context)),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            try {
                                              final authService = AuthService();
                                              await authService.logout();
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(isAmharic ? 'ተወጣሃል' : 'Logged out successfully'),
                                                    backgroundColor: Colors.green,
                                                  ),
                                                );
                                                // Navigate to login page
                                                context.go(AppConstants.loginRoute);
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(isAmharic ? 'ስህተት ተለመደ' : 'Logout failed'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            isAmharic ? 'አዎ' : 'Yes',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              );
                            },
                            child: Consumer(
                              builder: (context, ref, child) {
                                final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                return Text(
                                  isAmharic ? 'ውጣ' : 'Logout',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // About section
                    _buildSettingCard(
                      isDark: isDark,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.info,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isAmharic ? 'ስለ አግሪኔስት' : 'About AgriNest',
                                          style: TextStyle(
                                            color: AppStyles.textPrimary(context),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isAmharic ? 'ለኢትዮጵያ ያለ ብልህ አይኦቲ እርሻ መፍትሄ' : 'Smart IoT farming solution for Ethiopia',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    
                                    const SizedBox(width: 8),
                                    Text(
                                      'AASTU',
                                      style: TextStyle(
                                        color: AppStyles.textPrimary(context),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Group 81 – 2025',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Version ${AppConstants.version}',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // Bottom navigation bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface.withOpacity(0.9) : AppColors.surface.withOpacity(0.9),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.borderColor,
                      width: 1,
                    ),
                  ),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home, 'Home'),
                    _buildNavItem(1, Icons.bar_chart, 'Charts'),
                    _buildNavItem(2, Icons.settings, 'Settings'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
        );
      },
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    return Consumer(
      builder: (context, ref, child) {
        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
        final displayLabel = isAmharic
            ? (label == 'Home' ? 'ቤት' : label == 'Charts' ? 'ቻርት' : 'ቅንብሮች')
            : label;
        final isSelected = index == 2; // Settings is selected for settings screen

        return GestureDetector(
          onTap: () => _onNavItemTapped(index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryGreen : AppColors.darkTextSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                displayLabel,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryGreen : AppColors.darkTextSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingCard({required Widget child, required bool isDark}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard.withOpacity(0.5) : AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderColor,
          width: 1,
        ),
        boxShadow: isDark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildNotificationToggle(
    String label,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen,
            activeTrackColor: AppColors.primaryGreen.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
