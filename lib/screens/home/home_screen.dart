import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/circular_gauge.dart';
import '../../widgets/common/status_gauge.dart';
import '../../widgets/common/pump_status_card.dart';
import '../../services/user_service.dart';
import '../../services/pump_service.dart';
import '../../models/app_user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final UserService _userService = UserService();
  final PumpService _pumpService = PumpService();
  bool _pumpStatus = true; // Default to ON for demonstration
  bool _isPumping = false; // Loading state for pump button

  // Helper method to calculate soil status from moisture percentage
  Map<String, dynamic> _getSoilStatus(double moisture) {
    String status;
    Color statusColor;
    IconData icon;

    if (moisture < 30) {
      status = 'Dry';
      statusColor = AppColors.error;
      icon = Icons.water_drop_outlined;
    } else if (moisture >= 30 && moisture <= 70) {
      status = 'Optimal';
      statusColor = AppColors.success;
      icon = Icons.water_drop;
    } else {
      status = 'Wet';
      statusColor = AppColors.warning;
      icon = Icons.water_drop;
    }

    return {
      'status': status,
      'color': statusColor,
      'icon': icon,
    };
  }

  final List<Map<String, dynamic>> _gauges = [
    {
      'label': 'Soil Moisture',
      'value': 68.0,
      'unit': '%',
      'color': AppColors.soilMoisture,
      'icon': Icons.water_drop,
    },
    {
      'label': 'Temperature',
      'value': 26.4,
      'unit': '°C',
      'color': AppColors.temperature,
      'icon': Icons.thermostat,
    },
    {
      'label': 'Humidity',
      'value': 58.0,
      'unit': '%',
      'color': AppColors.humidity,
      'icon': Icons.air,
    },
    {
      'label': 'Light',
      'value': 820.0,
      'unit': 'lux',
      'color': AppColors.lightSensor,
      'icon': Icons.wb_sunny,
    },
    {
      'label': 'Battery',
      'value': 3.8,
      'unit': 'V',
      'color': AppColors.battery,
      'icon': Icons.battery_full,
    },
  ];

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        // Already on home
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 1:
        context.go(AppConstants.analyticsRoute);
        break;
      case 2:
        context.go(AppConstants.settingsRoute);
        break;
    }
  }

  Future<void> _showPumpConfirmationDialog(BuildContext context, WidgetRef ref) async {
    final isAmharic = ref.read(languageProvider).languageCode == 'am';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.water_drop,
                color: AppColors.primaryGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isAmharic ? 'ውሃ መግፋት' : 'Pump Water',
                style: AppStyles.headerTitle(context, isAmharic).copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            isAmharic
                ? 'ውሃን ማግፋት መጀመር መፈለግዎን እርግጠኛ ነዎት?'
                : 'Are you sure you want to activate the water pump?',
            style: AppStyles.subtitle(context),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                isAmharic ? 'ተወ' : 'Cancel',
                style: TextStyle(
                  color: AppStyles.textSecondary(context),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                isAmharic ? 'አግፋ' : 'Activate',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _activatePump(context, ref);
    }
  }

  Future<void> _activatePump(BuildContext context, WidgetRef ref) async {
    final isAmharic = ref.read(languageProvider).languageCode == 'am';
    
    setState(() {
      _isPumping = true;
    });

    try {
      final success = await _pumpService.activatePump();
      
      if (mounted) {
        setState(() {
          _isPumping = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  isAmharic
                      ? 'ውሃ በተሳካ ሁኔታ ተጀመረ!'
                      : 'Water pump activated successfully!',
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
        setState(() {
          _isPumping = false;
        });

        // Show error message
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
              color: AppStyles.background(context),
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
                decoration: AppStyles.headerDecoration(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        final uid = FirebaseAuth.instance.currentUser?.uid;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAmharic ? AppConstants.appNameAmharic : AppConstants.appName,
                              style: AppStyles.headerTitle(context, isAmharic),
                            ),
                            const SizedBox(height: 4),
                            if (uid != null)
                              FutureBuilder<AppUser?>(
                                future: _userService.getUserProfile(uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text(
                                      isAmharic ? 'በማልቀስ...' : 'Loading...',
                                      style: AppStyles.subtitle(context),
                                    );
                                  }

                                  if (snapshot.hasError || !snapshot.hasData) {
                                    return Text(
                                      isAmharic ? 'እንኳን ደህና መጡ!' : 'Welcome back!',
                                      style: AppStyles.subtitle(context),
                                    );
                                  }

                                  final user = snapshot.data!;
                                  return Text(
                                    isAmharic
                                      ? 'ሰላም ${user.name}! 👋'
                                      : 'Hello ${user.name}! 👋',
                                    style: AppStyles.subtitle(context),
                                  );
                                },
                              )
                            else
                              Text(
                                isAmharic ? 'እንኳን ደህና መጡ!' : 'Welcome back!',
                                style: AppStyles.subtitle(context),
                              ),
                          ],
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    // Pump Status Card - Full width first row
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: PumpStatusCard(
                              label: 'Pump Status',
                              isOn: _pumpStatus,
                              icon: Icons.power_settings_new,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Sensor gauges - Proportional grid layout
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate width so 2 widgets = pump button width
                        // Button width = screenWidth - 32 (16px padding each side)
                        // 2 widgets width = screenWidth - 32, with 12px spacing between
                        final screenWidth = constraints.maxWidth;
                        final itemWidth = (screenWidth - 32 - 12) / 2; // Account for padding and spacing
                        
                        // Get soil moisture value for status calculation
                        final soilMoisture = _gauges[0]['value'] as double;
                        final soilStatus = _getSoilStatus(soilMoisture);
                        
                        // Create combined list with all widgets
                        final allWidgets = <Map<String, dynamic>>[
                          ..._gauges,
                          {
                            'label': 'Soil Status',
                            'type': 'status',
                            'status': soilStatus['status'],
                            'color': soilStatus['color'],
                            'icon': soilStatus['icon'],
                          },
                        ];
                        
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.start,
                          children: allWidgets.asMap().entries.map((entry) {
                            final index = entry.key;
                            final widget = entry.value;
                            
                            return TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 700 + (index * 100)),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: value,
                                    child: SizedBox(
                                      width: itemWidth,
                                      child: widget['type'] == 'status'
                                          ? StatusGauge(
                                              label: widget['label'],
                                              status: widget['status'],
                                              statusColor: widget['color'],
                                              icon: widget['icon'],
                                            )
                                          : CircularGauge(
                                              label: widget['label'],
                                              value: widget['value'],
                                              unit: widget['unit'],
                                              color: widget['color'],
                                              icon: widget['icon'],
                                            ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 64),

                    // Pump Water Button
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isPumping
                                ? null
                                : () => _showPumpConfirmationDialog(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              disabledBackgroundColor: AppColors.primaryGreen.withOpacity(0.6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 2,
                            ),
                            child: _isPumping
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
                                        isAmharic ? 'በማግፋት ላይ...' : 'Activating...',
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
                                      const Icon(Icons.water_drop, size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        isAmharic ? 'ውሃ አግፋ' : 'Pump Water',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                decoration: AppStyles.navBarDecoration(context),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        return _buildNavItem(context, 0, Icons.home, isAmharic ? 'ቤት' : 'Home');
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        return _buildNavItem(context, 1, Icons.bar_chart, isAmharic ? 'ቻርት' : 'Charts');
                      },
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        return _buildNavItem(context, 2, Icons.settings, isAmharic ? 'ቅንብሮች' : 'Settings');
                      },
                    ),
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

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryGreen : AppStyles.textSecondary(context),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.navLabel(context, isSelected),
          ),
        ],
      ),
    );
  }
}
