import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import '../../services/auth_service.dart';
import '../../services/csv_export_service.dart';
import '../../services/thingspeak_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _switchController;
  late final CsvExportService _csvExportService;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    final thingSpeakService = ThingSpeakService();
    _csvExportService = CsvExportService(thingSpeakService);
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
              top: 16,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
              bottom: 80,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 24),
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
                              return Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isDark ? Icons.dark_mode : Icons.light_mode,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Consumer(
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
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAmharic ? 'ጨለማ ወይም ብርሃን ሁነታ' : 'Switch between dark and light mode',
                                      style: TextStyle(
                                        color: AppStyles.textSecondary(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Consumer(
                            builder: (context, ref, child) {
                              final themeMode = ref.watch(themeModeProvider);
                              final isDark = themeMode == ThemeMode.dark;

                              return GestureDetector(
                                onTap: () {
                                  ref.read(themeModeProvider.notifier).toggleTheme();
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  width: 52,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: isDark ? AppColors.primaryGreen : Colors.grey[400],
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
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
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.language,
                              color: AppColors.primaryGreen,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Language',
                                  style: TextStyle(
                                    color: AppStyles.textPrimary(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                    return Text(
                                      isAmharic ? 'ቋንቋ ይምረጡ' : 'Choose your preferred language',
                                      style: TextStyle(
                                        color: AppStyles.textSecondary(context),
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Consumer(
                            builder: (context, ref, child) {
                              final isAmharic = ref.watch(languageProvider).languageCode == 'am';

                              return GestureDetector(
                                onTap: () {
                                  ref.read(languageProvider.notifier).toggleLanguage();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isAmharic ? 'አማርኛ' : 'English',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isAmharic = ref.watch(languageProvider).languageCode == 'am';

                          return ElevatedButton(
                            onPressed: _isExporting
                                ? null
                                : () => _exportCsvData(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.6),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isExporting
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isAmharic ? 'በማውጣት ላይ...' : 'Exporting...',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.download,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          isAmharic
                                              ? '30 ቀናት መረጃ ወደ CSV ላክ'
                                              : 'Export 30 days Data as CSV',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
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

                    const SizedBox(height: 16),

                    // Profile section
                    _buildSettingCard(
                      isDark: isDark,
                      child: InkWell(
                        onTap: () {
                          context.go(AppConstants.editProfileRoute);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppColors.primaryGreen,
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
                                      return Text(
                                        isAmharic ? 'መለያ አርትዕ' : 'Edit Profile',
                                        style: TextStyle(
                                          color: AppStyles.textPrimary(context),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                      return Text(
                                        isAmharic ? 'የግል መረጃዎን ይለውጡ' : 'Update your personal information',
                                        style: TextStyle(
                                          color: AppStyles.textSecondary(context),
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppStyles.textSecondary(context),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Logout section
                    _buildSettingCard(
                      isDark: isDark,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: AppColors.error,
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
                                    return Text(
                                      isAmharic ? 'ውጣ' : 'Logout',
                                      style: TextStyle(
                                        color: AppStyles.textPrimary(context),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                                    return Text(
                                      isAmharic ? 'ከመለያዎ ይውጡ' : 'Sign out from your account',
                                      style: TextStyle(
                                        color: AppStyles.textSecondary(context),
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ],
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
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.info,
                              color: AppColors.primaryGreen,
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
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          isAmharic ? 'ለኢትዮጵያ ያለ ብልህ አይኦቲ እርሻ መፍትሄ' : 'Smart IoT farming solution for Ethiopia',
                                          style: TextStyle(
                                            color: AppStyles.textSecondary(context),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'AASTU • Group 81 – 2025',
                                  style: TextStyle(
                                    color: AppStyles.textSecondary(context),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Version ${AppConstants.version}',
                                  style: TextStyle(
                                    color: AppStyles.textMuted(context),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
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
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppStyles.card(context),
        border: Border(
          top: BorderSide(
            color: AppStyles.border(context).withOpacity(0.2),
            width: 1,
          ),
          bottom: BorderSide(
            color: AppStyles.border(context).withOpacity(0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _exportCsvData(BuildContext context, WidgetRef ref) async {
    final isAmharic = ref.read(languageProvider).languageCode == 'am';

    setState(() {
      _isExporting = true;
    });

    try {
      // Export data (handles sharing/download automatically)
      await _csvExportService.export30DaysData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  isAmharic
                      ? '30 ቀናት መረጃ በተሳካ ሁኔታ ተወጣ!'
                      : '30 days data exported successfully!',
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAmharic
                        ? 'ስህተት: ${e.toString()}'
                        : 'Error: ${e.toString()}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}
