import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../providers/sensor_data_provider.dart';
import '../../models/sensor_data.dart';
import '../../widgets/common/circular_gauge.dart';
import '../../widgets/common/status_gauge.dart';
import '../../widgets/common/pump_status_card.dart';
import '../../services/user_service.dart';
import '../../services/pump_service.dart';
import '../../services/thingspeak_service.dart';
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
  final ThingSpeakService _thingSpeakService = ThingSpeakService();
  bool _isPumping = false; // Loading state for pump button
  bool? _optimisticPumpState; // Optimistic pump state update
  DateTime? _lastPumpUpdate; // Track last pump update for rate limiting
  late AnimationController _skeletonController;

  @override
  void initState() {
    super.initState();
    // Animation controller for skeleton loaders
    _skeletonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _skeletonController.dispose();
    super.dispose();
  }

  // Helper method to calculate soil status from moisture percentage
  Map<String, dynamic> _getSoilStatus(double? moisture, BuildContext context) {
    if (moisture == null) {
      return {
        'status': 'Unknown',
        'color': AppStyles.textSecondary(context),
        'icon': Icons.help_outline,
      };
    }

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

  // Build skeleton loader for pump status card
  Widget _buildPumpStatusSkeleton(BuildContext context) {
    return AnimatedBuilder(
      animation: _skeletonController,
      builder: (context, child) {
        final opacity = 0.5 + (_skeletonController.value * 0.3);
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppStyles.card(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppStyles.textSecondary(context).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppStyles.textSecondary(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppStyles.textSecondary(context).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 60,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppStyles.textSecondary(context).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppStyles.textSecondary(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build skeleton loader for circular gauge
  Widget _buildCircularGaugeSkeleton(BuildContext context) {
    return AnimatedBuilder(
      animation: _skeletonController,
      builder: (context, child) {
        final opacity = 0.5 + (_skeletonController.value * 0.3);
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppStyles.cardDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppStyles.textSecondary(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: CircularProgressIndicator(
                          value: 1.0,
                          strokeWidth: 6,
                          backgroundColor: AppStyles.textSecondary(context).withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppStyles.textSecondary(context).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppStyles.textSecondary(context).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build skeleton loader for status gauge
  Widget _buildStatusGaugeSkeleton(BuildContext context) {
    return AnimatedBuilder(
      animation: _skeletonController,
      builder: (context, child) {
        final opacity = 0.5 + (_skeletonController.value * 0.3);
        return Opacity(
          opacity: opacity,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: AppStyles.cardDecoration(context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppStyles.textSecondary(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppStyles.textSecondary(context).withOpacity(0.1),
                    border: Border.all(
                      color: AppStyles.textSecondary(context).withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppStyles.textSecondary(context).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Build gauges list from sensor data
  List<Map<String, dynamic>> _buildGauges(SensorData? sensorData, BuildContext context) {
    // Use fetched data if available, otherwise use fallback values
    final soilMoisture = sensorData?.soilMoisture ?? 0.0;
    final temperature = sensorData?.temperature ?? 0.0;
    final humidity = sensorData?.humidity ?? 0.0;
    final light = sensorData?.light ?? 0.0;
    final battery = sensorData?.battery ?? 0.0;

    return [
      {
        'label': 'Soil Moisture',
        'value': soilMoisture,
        'unit': '%',
        'color': AppColors.soilMoisture,
        'icon': Icons.water_drop,
        'hasData': sensorData?.soilMoisture != null,
      },
      {
        'label': 'Temperature',
        'value': temperature,
        'unit': '°C',
        'color': AppColors.temperature,
        'icon': Icons.thermostat,
        'hasData': sensorData?.temperature != null,
      },
      {
        'label': 'Humidity',
        'value': humidity,
        'unit': '%',
        'color': AppColors.humidity,
        'icon': Icons.air,
        'hasData': sensorData?.humidity != null,
      },
      {
        'label': 'Light',
        'value': light,
        'unit': 'lux',
        'color': AppColors.lightSensor,
        'icon': Icons.wb_sunny,
        'hasData': sensorData?.light != null,
      },
      {
        'label': 'Battery',
        'value': battery,
        'unit': 'V',
        'color': AppColors.battery,
        'icon': Icons.battery_full,
        'hasData': sensorData?.battery != null,
      },
    ];
  }

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

  Future<void> _showPumpConfirmationDialog(BuildContext context, WidgetRef ref, bool isCurrentlyOn) async {
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
                isCurrentlyOn ? Icons.stop_circle : Icons.water_drop,
                color: isCurrentlyOn ? AppColors.error : AppColors.primaryGreen,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isCurrentlyOn 
                    ? (isAmharic ? 'ውሃ ማቆም' : 'Stop Water')
                    : (isAmharic ? 'ውሃ መግፋት' : 'Pump Water'),
                style: AppStyles.headerTitle(context, isAmharic).copyWith(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Text(
            isCurrentlyOn
                ? (isAmharic
                    ? 'ውሃን ማቆም መፈለግዎን እርግጠኛ ነዎት?'
                    : 'Are you sure you want to stop the water pump?')
                : (isAmharic
                    ? 'ውሃን ማግፋት መጀመር መፈለግዎን እርግጠኛ ነዎት?'
                    : 'Are you sure you want to activate the water pump?'),
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
                backgroundColor: isCurrentlyOn ? AppColors.error : AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                isCurrentlyOn 
                    ? (isAmharic ? 'አቁም' : 'Stop')
                    : (isAmharic ? 'አግፋ' : 'Activate'),
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
      await _togglePump(context, ref, isCurrentlyOn);
    }
  }

  Future<void> _handleRefresh(BuildContext context, WidgetRef ref) async {
    final isAmharic = ref.read(languageProvider).languageCode == 'am';
    
    // Check connectivity first
    final connectivityAsync = ref.read(connectivityProvider);
    final connectivityStatus = connectivityAsync.valueOrNull;
    final isOnline = connectivityStatus == ConnectionStatus.online;
    
    if (!isOnline) {
      // Show offline message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isAmharic
                        ? 'እባክዎ ወደ ኢንተርኔት ይገናኙ'
                        : 'Please connect to internet',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return;
    }
    
    // Refresh data
    try {
      debugPrint('[LOG home_screen] ========= Refreshing sensor data from API...');
      ref.invalidate(sensorDataProvider);
      await Future.delayed(const Duration(milliseconds: 100));
      await ref.refresh(sensorDataProvider);
    } catch (e) {
      // Show error message
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
                        ? 'ውሂብ ማዘምን አልተሳካም: ${e.toString()}'
                        : 'Failed to refresh data: ${e.toString()}',
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _togglePump(BuildContext context, WidgetRef ref, bool isCurrentlyOn) async {
    final isAmharic = ref.read(languageProvider).languageCode == 'am';
    
    // Check rate limiting (15 seconds minimum between writes)
    if (_lastPumpUpdate != null) {
      final timeSinceLastUpdate = DateTime.now().difference(_lastPumpUpdate!);
      if (timeSinceLastUpdate.inSeconds < 15) {
        final remainingSeconds = 15 - timeSinceLastUpdate.inSeconds;
        if (mounted) {
          final rateLimitMessage = isAmharic
              ? 'እባክዎ $remainingSeconds ሰከንድ ይጠብቁ'
              : 'Please wait $remainingSeconds seconds';
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      rateLimitMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.warning,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }
    
    setState(() {
      _isPumping = true;
    });

    // Optimistically update UI immediately
    final newState = !isCurrentlyOn;
    setState(() {
      _optimisticPumpState = newState;
    });

    try {
      // Write to ThingSpeak field8
      final success = await _thingSpeakService.updatePumpState(newState);
      
      if (!success) {
        throw Exception('Failed to update pump state');
      }
      
      // Update last pump update time
      _lastPumpUpdate = DateTime.now();
      
      // Refetch latest data to confirm (in background)
      ref.refresh(sensorDataProvider);
      
      if (mounted) {
        setState(() {
          _isPumping = false;
          // Keep optimistic state until provider updates
        });

        // Show success message
        final successMessage = newState
            ? (isAmharic
                ? 'ውሃ በተሳካ ሁኔታ ተጀመረ!'
                : 'Water pump activated successfully!')
            : (isAmharic
                ? 'ውሃ በተሳካ ሁኔታ ተቆጠረ!'
                : 'Water pump stopped successfully!');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    successMessage,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        setState(() {
          _isPumping = false;
          _optimisticPumpState = null; // Clear optimistic state
        });

        // Show error message
        final errorMessage = isAmharic
            ? 'ስህተት: ${e.toString()}'
            : 'Error: ${e.toString()}';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white),
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
      
      // Refresh provider to get actual state
      ref.refresh(sensorDataProvider);
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
              top: 16,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: AppStyles.headerDecoration(context),
                child: Consumer(
                  builder: (context, ref, child) {
                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                    final connectivityAsync = ref.watch(connectivityProvider);
                    final sensorDataAsync = ref.watch(sensorDataProvider);
                    
                    // Determine connection status and text
                    final statusInfo = connectivityAsync.when(
                      data: (status) {
                        if (status == ConnectionStatus.online) {
                          return {
                            'text': isAmharic ? 'መስመር ላይ' : 'Online',
                            'color': AppColors.primaryGreen,
                          };
                        } else if (status == ConnectionStatus.checking) {
                          return {
                            'text': isAmharic ? 'በመፈተሽ...' : 'Checking...',
                            'color': AppStyles.textSecondary(context),
                          };
                        } else {
                          return {
                            'text': isAmharic ? 'ከመስመር ውጭ' : 'Offline',
                            'color': AppColors.error,
                          };
                        }
                      },
                      loading: () => {
                        'text': isAmharic ? 'በመፈተሽ...' : 'Checking...',
                        'color': AppStyles.textSecondary(context),
                      },
                      error: (_, __) => {
                        'text': isAmharic ? 'ከመስመር ውጭ' : 'Offline',
                        'color': AppColors.error,
                      },
                    );
                    
                    final isRefreshing = sensorDataAsync.isLoading;
                    
                    return Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                isAmharic ? AppConstants.appNameAmharic : AppConstants.appName,
                                style: AppStyles.headerTitle(context, isAmharic).copyWith(
                                  fontSize: isAmharic ? 20 : 22,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppStyles.textSecondary(context),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                statusInfo['text'] as String,
                                style: AppStyles.subtitle(context).copyWith(
                                  fontSize: 13,
                                  color: statusInfo['color'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Refresh button
                        IconButton(
                          onPressed: isRefreshing
                              ? null
                              : () async {
                                  await _handleRefresh(context, ref);
                                },
                          icon: isRefreshing
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryGreen,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.refresh,
                                  color: AppColors.primaryGreen,
                                  size: 24,
                                ),
                          tooltip: isAmharic ? 'አድስ' : 'Refresh',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // Scrollable content
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              bottom: 80,
              child: Consumer(
                builder: (context, ref, child) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await _handleRefresh(context, ref);
                    },
                    color: AppColors.primaryGreen,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      child: Column(
                        children: [
                          // Pump Status Card - Full width first row with top margin
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final sensorDataAsync = ref.watch(sensorDataProvider);
                                
                                return sensorDataAsync.when(
                                  data: (sensorData) {
                                    // Use pump status from API (defaults to false if null)
                                    final pumpStatus = sensorData?.pumpStatus ?? false;
                                    
                                    return TweenAnimationBuilder<double>(
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
                                              isOn: pumpStatus,
                                              icon: Icons.power_settings_new,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  loading: () => _buildPumpStatusSkeleton(context),
                                  error: (error, stack) {
                                    // Show fallback status on error
                                    return TweenAnimationBuilder<double>(
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
                                              isOn: false, // Default to OFF on error
                                              icon: Icons.power_settings_new,
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                    // Sensor gauges - Proportional grid layout
                    Consumer(
                      builder: (context, ref, child) {
                        final sensorDataAsync = ref.watch(sensorDataProvider);
                        
                        return sensorDataAsync.when(
                          data: (sensorData) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                // Calculate width so 2 widgets = pump button width
                                final screenWidth = constraints.maxWidth;
                                final itemWidth = (screenWidth - 32 - 12) / 2;
                                
                                // Build gauges from sensor data
                                final gauges = _buildGauges(sensorData, context);
                                
                                // Get soil moisture value for status calculation
                                final soilMoisture = sensorData?.soilMoisture;
                                final soilStatus = _getSoilStatus(soilMoisture, context);
                                
                                // Create combined list with all widgets
                                final allWidgets = <Map<String, dynamic>>[
                                  ...gauges,
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
                                                      status: widget['status'] as String,
                                                      statusColor: widget['color'] as Color,
                                                      icon: widget['icon'] as IconData,
                                                    )
                                                  : CircularGauge(
                                                      label: widget['label'] as String,
                                                      value: widget['value'] as double,
                                                      unit: widget['unit'] as String,
                                                      color: widget['color'] as Color,
                                                      icon: widget['icon'] as IconData,
                                                    ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                          loading: () => LayoutBuilder(
                            builder: (context, constraints) {
                              final screenWidth = constraints.maxWidth;
                              final itemWidth = (screenWidth - 32 - 12) / 2;
                              
                              // Show skeleton loaders for 6 widgets (5 gauges + 1 status)
                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.start,
                                children: List.generate(6, (index) {
                                  return SizedBox(
                                    width: itemWidth,
                                    child: index == 5
                                        ? _buildStatusGaugeSkeleton(context)
                                        : _buildCircularGaugeSkeleton(context),
                                  );
                                }),
                              );
                            },
                          ),
                          error: (error, stack) {
                            debugPrint('[LOG home_screen] ========= Error loading sensor data: $error');
                            
                            // Show error popup message
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final isAmharic = ref.read(languageProvider).languageCode == 'am';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.white),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          isAmharic
                                              ? 'ውሂብ ማስተናገድ አልተሳካም. እባክዎን እንደገና ይሞክሩ.'
                                              : 'Failed to load data. Please try again.',
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
                            });
                            
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                final screenWidth = constraints.maxWidth;
                                final itemWidth = (screenWidth - 32 - 12) / 2;
                                
                                // Show error state with fallback data
                                final gauges = _buildGauges(null, context);
                                final soilStatus = _getSoilStatus(null, context);
                                
                                final allWidgets = <Map<String, dynamic>>[
                                  ...gauges,
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
                                    
                                    return SizedBox(
                                      width: itemWidth,
                                      child: widget['type'] == 'status'
                                          ? StatusGauge(
                                              label: widget['label'] as String,
                                              status: widget['status'] as String,
                                              statusColor: widget['color'] as Color,
                                              icon: widget['icon'] as IconData,
                                            )
                                          : CircularGauge(
                                              label: widget['label'] as String,
                                              value: widget['value'] as double,
                                              unit: widget['unit'] as String,
                                              color: widget['color'] as Color,
                                              icon: widget['icon'] as IconData,
                                            ),
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 64),

                    // Pump Water Button
                    Consumer(
                      builder: (context, ref, child) {
                        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                        final sensorDataAsync = ref.watch(sensorDataProvider);
                        
                        return sensorDataAsync.when(
                          data: (sensorData) {
                            // Use optimistic state if available, otherwise use provider data
                            final isPumpOn = _optimisticPumpState ?? (sensorData?.manualPumpControl ?? false);
                            
                            // Clear optimistic state once provider has updated
                            if (_optimisticPumpState != null && sensorData != null) {
                              final providerState = sensorData.manualPumpControl ?? false;
                              if (_optimisticPumpState == providerState) {
                                // Provider has caught up, clear optimistic state
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  if (mounted) {
                                    setState(() {
                                      _optimisticPumpState = null;
                                    });
                                  }
                                });
                              }
                            }
                            
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isPumping
                                    ? null
                                    : () => _showPumpConfirmationDialog(context, ref, isPumpOn),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isPumpOn ? AppColors.error : AppColors.primaryGreen,
                                  disabledBackgroundColor: (isPumpOn ? AppColors.error : AppColors.primaryGreen).withOpacity(0.6),
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
                                            isPumpOn
                                                ? (isAmharic ? 'በማቆም ላይ...' : 'Stopping...')
                                                : (isAmharic ? 'በማግፋት ላይ...' : 'Activating...'),
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
                                          Icon(
                                            isPumpOn ? Icons.stop_circle : Icons.water_drop,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            isPumpOn
                                                ? (isAmharic ? 'ውሃ አቁም' : 'Stop Water')
                                                : (isAmharic ? 'ውሃ አግፋ' : 'Pump Water'),
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
                          loading: () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen.withOpacity(0.6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
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
                                    isAmharic ? 'በመጫን ላይ...' : 'Loading...',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          error: (error, stack) => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error.withOpacity(0.6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    isAmharic ? 'ስህተት' : 'Error',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
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
