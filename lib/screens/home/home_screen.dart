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
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../services/user_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final UserService _userService = UserService();

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
    {
      'label': 'Water Used',
      'value': 142.0,
      'unit': 'ml',
      'color': AppColors.waterUsed,
      'icon': Icons.water,
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Sensor gauges grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: _gauges.length,
                      itemBuilder: (context, index) {
                        final gauge = _gauges[index];
                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 600 + (index * 100)),
                          curve: Curves.easeOut,
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: value,
                              child: Opacity(
                                opacity: value,
                                child: CircularGauge(
                                  label: gauge['label'],
                                  value: gauge['value'],
                                  unit: gauge['unit'],
                                  color: gauge['color'],
                                  icon: gauge['icon'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
