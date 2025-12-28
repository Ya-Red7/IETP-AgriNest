import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui' as ui;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/sensor_data_provider.dart';
import '../../providers/chart_data_provider.dart';
import '../../models/chart_data.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  String _selectedPeriod = '7days';

  void _onNavItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.homeRoute);
        break;
      case 1:
        // Already on analytics/charts
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
              top: 16,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: AppStyles.headerDecoration(context),
                child: Consumer(
                  builder: (context, ref, child) {
                    final isAmharic = ref.watch(languageProvider).languageCode == 'am';
                    final sensorDataAsync = ref.watch(sensorDataProvider);
                    final isRefreshing = sensorDataAsync.isLoading;
                    
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            isAmharic ? 'የውሂብ ትንተና' : 'Analytics',
                            style: AppStyles.headerTitle(context, isAmharic),
                          ),
                        ),
                        // Refresh button
                        IconButton(
                          onPressed: isRefreshing
                              ? null
                              : () {
                                  // Refresh all chart data providers
                                  ref.invalidate(chartData24hProvider);
                                  ref.invalidate(chartData7dProvider);
                                  ref.invalidate(chartData30dProvider);
                                  ref.refresh(sensorDataProvider);
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

            // Tabs
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: AppStyles.surface(context).withOpacity(0.3),
                child: Row(
                  children: [
                    _buildPeriodTab(context, '24h', '24h'),
                    const SizedBox(width: 8),
                    _buildPeriodTab(context, '7days', '7 days'),
                    const SizedBox(width: 8),
                    _buildPeriodTab(context, '30days', '30 days'),
                  ],
                ),
              ),
            ),

            // Scrollable content
            Positioned(
              top: 180,
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer(
                builder: (context, ref, child) {
                  // Get the appropriate provider based on selected period
                  final chartDataAsync = _selectedPeriod == '24h'
                      ? ref.watch(chartData24hProvider)
                      : _selectedPeriod == '7days'
                          ? ref.watch(chartData7dProvider)
                          : ref.watch(chartData30dProvider);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Chart
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: AppStyles.cardDecoration(context),
                          child: chartDataAsync.when(
                            data: (chartData) {
                              if (chartData.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.bar_chart_outlined,
                                        size: 48,
                                        color: AppStyles.textSecondary(context),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No data available',
                                        style: AppStyles.legendText(context),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  SizedBox(
                                    height: 200,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(
                                          show: true,
                                          drawVerticalLine: true,
                                          getDrawingHorizontalLine: (value) {
                                            return AppStyles.chartGridLine(context);
                                          },
                                          getDrawingVerticalLine: (value) {
                                            return AppStyles.chartGridLine(context);
                                          },
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              getTitlesWidget: (value, meta) {
                                                final index = value.toInt();
                                                if (index >= 0 && index < chartData.length) {
                                                  final dataPoint = chartData[index];
                                                  String label;
                                                  switch (_selectedPeriod) {
                                                    case '24h':
                                                      // Show every 6th hour for readability
                                                      if (index % 6 == 0) {
                                                        label = '${dataPoint.timestamp.hour}:00';
                                                      } else {
                                                        label = '';
                                                      }
                                                      break;
                                                    case '7days':
                                                      final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                                                      label = days[dataPoint.timestamp.weekday - 1];
                                                      break;
                                                    case '30days':
                                                      // Show every 5th day for readability
                                                      if (index % 5 == 0) {
                                                        label = '${dataPoint.timestamp.month}/${dataPoint.timestamp.day}';
                                                      } else {
                                                        label = '';
                                                      }
                                                      break;
                                                    default:
                                                      label = '';
                                                  }
                                                  return Text(
                                                    label,
                                                    style: AppStyles.legendText(context),
                                                  );
                                                }
                                                return const Text('');
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 40,
                                              getTitlesWidget: (value, meta) {
                                                return Text(
                                                  value.toStringAsFixed(0),
                                                  style: AppStyles.legendText(context),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        borderData: FlBorderData(
                                          show: false,
                                        ),
                                        lineBarsData: [
                                          // Soil Moisture Line
                                          LineChartBarData(
                                            spots: chartData.asMap().entries.map((entry) {
                                              return FlSpot(entry.key.toDouble(), entry.value.avgSoilMoisture);
                                            }).toList(),
                                            isCurved: true,
                                            color: AppColors.soilMoisture,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(
                                              show: false, // Hide dots for cleaner look with aggregated data
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                            ),
                                          ),
                                          // Temperature Line
                                          LineChartBarData(
                                            spots: chartData.asMap().entries.map((entry) {
                                              return FlSpot(entry.key.toDouble(), entry.value.avgTemperature);
                                            }).toList(),
                                            isCurved: true,
                                            color: AppColors.temperature,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(
                                              show: false, // Hide dots for cleaner look with aggregated data
                                            ),
                                            belowBarData: BarAreaData(
                                              show: false,
                                            ),
                                          ),
                                        ],
                                        lineTouchData: LineTouchData(
                                          touchTooltipData: LineTouchTooltipData(
                                            getTooltipItems: (touchedSpots) {
                                              return touchedSpots.map((spot) {
                                                final isMoisture = spot.barIndex == 0;
                                                final dataPoint = chartData[spot.spotIndex];
                                                final value = isMoisture
                                                    ? dataPoint.avgSoilMoisture
                                                    : dataPoint.avgTemperature;
                                                final unit = isMoisture ? '%' : '°C';
                                                final label = isMoisture ? 'Moisture' : 'Temp';

                                                return LineTooltipItem(
                                                  '$label: ${value.toStringAsFixed(1)}$unit',
                                                  TextStyle(
                                                    color: isMoisture ? AppColors.soilMoisture : AppColors.temperature,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Legend
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildLegendItem('Soil Moisture (%)', AppColors.soilMoisture),
                                        const SizedBox(width: 24),
                                        _buildLegendItem('Temperature (°C)', AppColors.temperature),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                            loading: () => Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: _buildChartSkeleton(context),
                                ),
                                // Legend skeleton
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _buildLegendSkeleton(context),
                                      const SizedBox(width: 24),
                                      _buildLegendSkeleton(context),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            error: (error, stack) => Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.error,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Failed to load chart data',
                                    style: AppStyles.legendText(context),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    error.toString(),
                                    style: AppStyles.legendText(context).copyWith(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                    const SizedBox(height: 16),

                    // Water saving card
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: Opacity(
                            opacity: value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primaryGreen,
                                    AppColors.primaryGreen.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.glassBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.water_drop,
                                      color: Colors.white,
                                      size: 32,
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
                                            return RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: _getPeriodText(isAmharic),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: _getWaterSavedValue().toString(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: isAmharic ? ' ሊትር ውሃ አስቀመጥክ' : ' liters of water',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ],
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

                    // Additional insights
                    Consumer(
                      builder: (context, ref, child) {
                        final chartDataAsync = _selectedPeriod == '24h'
                            ? ref.watch(chartData24hProvider)
                            : _selectedPeriod == '7days'
                                ? ref.watch(chartData7dProvider)
                                : ref.watch(chartData30dProvider);

                        return chartDataAsync.when(
                          data: (chartData) {
                            if (chartData.isEmpty) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildInsightCard(
                                      context,
                                      'Avg Moisture',
                                      'N/A',
                                      'አማካኝ እርጥበት',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildInsightCard(
                                      context,
                                      'Avg Temp',
                                      'N/A',
                                      'አማካኝ ሙቀት',
                                    ),
                                  ),
                                ],
                              );
                            }

                            // Calculate averages from valid data points only
                            final validMoistureData = chartData
                                .map((d) => d.avgSoilMoisture)
                                .where((value) => value > 0)
                                .toList();
                            final validTempData = chartData
                                .map((d) => d.avgTemperature)
                                .where((value) => value > 0)
                                .toList();
                            
                            final avgMoisture = validMoistureData.isNotEmpty
                                ? validMoistureData.reduce((a, b) => a + b) / validMoistureData.length
                                : 0.0;
                            final avgTemp = validTempData.isNotEmpty
                                ? validTempData.reduce((a, b) => a + b) / validTempData.length
                                : 0.0;

                            return Row(
                              children: [
                                Expanded(
                                  child: _buildInsightCard(
                                    context,
                                    'Avg Moisture',
                                    avgMoisture > 0
                                        ? '${avgMoisture.toStringAsFixed(1)}%'
                                        : 'N/A',
                                    'አማካኝ እርጥበት',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildInsightCard(
                                    context,
                                    'Avg Temp',
                                    avgTemp > 0
                                        ? '${avgTemp.toStringAsFixed(1)}°C'
                                        : 'N/A',
                                    'አማካኝ ሙቀት',
                                  ),
                                ),
                              ],
                            );
                          },
                          loading: () => Row(
                            children: [
                              Expanded(
                                child: _buildInsightCard(
                                  context,
                                  'Avg Moisture',
                                  '...',
                                  'አማካኝ እርጥበት',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInsightCard(
                                  context,
                                  'Avg Temp',
                                  '...',
                                  'አማካኝ ሙቀት',
                                ),
                              ),
                            ],
                          ),
                          error: (error, stack) => Row(
                            children: [
                              Expanded(
                                child: _buildInsightCard(
                                  context,
                                  'Avg Moisture',
                                  'N/A',
                                  'አማካኝ እርጥበት',
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInsightCard(
                                  context,
                                  'Avg Temp',
                                  'N/A',
                                  'አማካኝ ሙቀት',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),
                  ],
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
                    _buildNavItem(context, 0, Icons.home, 'Home'),
                    _buildNavItem(context, 1, Icons.bar_chart, 'Charts'),
                    _buildNavItem(context, 2, Icons.settings, 'Settings'),
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
    return Consumer(
      builder: (context, ref, child) {
        final isAmharic = ref.watch(languageProvider).languageCode == 'am';
        final displayLabel = isAmharic
            ? (label == 'Home' ? 'ቤት' : label == 'Charts' ? 'ቻርት' : 'ቅንብሮች')
            : label;
        final isSelected = index == 1; // Charts is selected for analytics screen

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
                displayLabel,
                style: AppStyles.navLabel(context, isSelected),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPeriodTab(BuildContext context, String period, String displayText) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedPeriod = period;
          });
          // Invalidate the provider to trigger a fresh fetch when tab changes
          // The provider will be watched in the build method, so it will fetch automatically
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: AppStyles.tabDecoration(context, isSelected),
          child: Center(
            child: Text(
              displayText,
              style: AppStyles.tabText(context, isSelected),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppStyles.legendText(context),
        ),
      ],
    );
  }

  Widget _buildChartSkeleton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: CustomPaint(
            size: const Size(double.infinity, 200),
            painter: _ChartSkeletonPainter(
              color: AppStyles.textSecondary(context).withOpacity(0.15),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegendSkeleton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.3, end: 0.7),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppStyles.textSecondary(context).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: AppStyles.textSecondary(context).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getPeriodText(bool isAmharic) {
    switch (_selectedPeriod) {
      case '24h':
        return isAmharic ? 'በዚህ ቀን ' : 'Today you saved ';
      case '7days':
        return isAmharic ? 'በዚህ ሳምንት ' : 'This week you saved ';
      case '30days':
        return isAmharic ? 'በዚህ ወር ' : 'This month you saved ';
      default:
        return isAmharic ? 'በዚህ ሳምንት ' : 'This week you saved ';
    }
  }

  String _getWaterSavedValue() {
    switch (_selectedPeriod) {
      case '24h':
        return '0.8';
      case '7days':
        return '2.1';
      case '30days':
        return '8.5';
      default:
        return '2.1';
    }
  }

  Widget _buildInsightCard(BuildContext context, String title, String value, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppStyles.card(context).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppStyles.border(context),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.insightTitle(context),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppStyles.insightValue(context),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppStyles.insightSubtitle(context),
          ),
        ],
      ),
    );
  }
}

class _ChartSkeletonPainter extends CustomPainter {
  final Color color;

  _ChartSkeletonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw grid lines (subtle)
    for (int i = 0; i <= 4; i++) {
      final y = size.height / 4 * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint..strokeWidth = 1,
      );
    }

    for (int i = 0; i <= 6; i++) {
      final x = size.width / 6 * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint..strokeWidth = 1,
      );
    }

    // Draw skeleton chart lines (curved)
    final path1 = Path();
    final path2 = Path();
    
    final points1 = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width, size.height * 0.45),
    ];

    final points2 = [
      Offset(0, size.height * 0.5),
      Offset(size.width * 0.2, size.height * 0.4),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.4),
      Offset(size.width, size.height * 0.35),
    ];

    // Draw first line (smooth curve)
    path1.moveTo(points1[0].dx, points1[0].dy);
    for (int i = 1; i < points1.length; i++) {
      final prev = points1[i - 1];
      final curr = points1[i];
      final controlPoint = Offset(
        (prev.dx + curr.dx) / 2,
        (prev.dy + curr.dy) / 2,
      );
      path1.quadraticBezierTo(controlPoint.dx, controlPoint.dy, curr.dx, curr.dy);
    }

    // Draw second line (smooth curve)
    path2.moveTo(points2[0].dx, points2[0].dy);
    for (int i = 1; i < points2.length; i++) {
      final prev = points2[i - 1];
      final curr = points2[i];
      final controlPoint = Offset(
        (prev.dx + curr.dx) / 2,
        (prev.dy + curr.dy) / 2,
      );
      path2.quadraticBezierTo(controlPoint.dx, controlPoint.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(path1, paint..strokeWidth = 2.5);
    canvas.drawPath(path2, paint..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
