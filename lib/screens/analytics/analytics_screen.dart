import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_styles.dart';
import '../../core/utils/constants.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with TickerProviderStateMixin {
  String _selectedPeriod = '7days';

  // Generate mock data based on selected period
  List<Map<String, dynamic>> get _mockData {
    return _generateMockData(_selectedPeriod);
  }

  List<Map<String, dynamic>> _generateMockData(String period) {
    final now = DateTime.now();
    List<Map<String, dynamic>> data = [];

    switch (period) {
      case '24h':
        // Generate data for last 24 hours (hourly data)
        for (int i = 23; i >= 0; i--) {
          final dateTime = now.subtract(Duration(hours: i));
          data.add({
            'time': '${dateTime.hour}:00',
            'moisture': 60.0 + (i % 10) + (i * 0.5).clamp(0, 15),
            'temp': 22.0 + (i % 8) + (i * 0.2).clamp(0, 8),
          });
        }
        break;

      case '7days':
        // Generate data for last 7 days (daily data)
        final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          data.add({
            'day': days[date.weekday - 1],
            'moisture': 60.0 + (i % 12) + (i * 0.8).clamp(0, 10),
            'temp': 23.0 + (i % 6) + (i * 0.3).clamp(0, 5),
          });
        }
        break;

      case '30days':
        // Generate data for last 30 days (daily data, showing every 3rd day for readability)
        for (int i = 29; i >= 0; i -= 3) {
          final date = now.subtract(Duration(days: i));
          data.add({
            'day': '${date.month}/${date.day}',
            'moisture': 55.0 + ((29 - i) % 15) + ((29 - i) * 0.2).clamp(0, 8),
            'temp': 20.0 + ((29 - i) % 10) + ((29 - i) * 0.1).clamp(0, 6),
          });
        }
        // Reverse to show chronological order
        data = data.reversed.toList();
        break;
    }

    return data;
  }

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
                        return Text(
                          isAmharic ? 'የውሂብ ትንተና' : 'Analytics',
                          style: AppStyles.headerTitle(context, isAmharic),
                        );
                      },
                    ),
                  ],
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Chart
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppStyles.cardDecoration(context),
                      child: Column(
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
                                        if (index >= 0 && index < _mockData.length) {
                                          String label;
                                          switch (_selectedPeriod) {
                                            case '24h':
                                              // Show every 6th hour for readability
                                              if (index % 6 == 0) {
                                                label = _mockData[index]['time'];
                                              } else {
                                                label = '';
                                              }
                                              break;
                                            case '7days':
                                              label = _mockData[index]['day'];
                                              break;
                                            case '30days':
                                              // Show every other date for readability
                                              if (index % 2 == 0) {
                                                label = _mockData[index]['day'];
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
                                    spots: _mockData.asMap().entries.map((entry) {
                                      return FlSpot(entry.key.toDouble(), entry.value['moisture']);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppColors.soilMoisture,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: AppColors.soilMoisture,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: false,
                                    ),
                                  ),
                                  // Temperature Line
                                  LineChartBarData(
                                    spots: _mockData.asMap().entries.map((entry) {
                                      return FlSpot(entry.key.toDouble(), entry.value['temp']);
                                    }).toList(),
                                    isCurved: true,
                                    color: AppColors.temperature,
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: AppColors.temperature,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
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
                                        final value = isMoisture
                                            ? _mockData[spot.spotIndex]['moisture']
                                            : _mockData[spot.spotIndex]['temp'];
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
                    Builder(
                      builder: (context) {
                        final avgMoisture = _calculateAverage('moisture');
                        final avgTemp = _calculateAverage('temp');

                        return Row(
                          children: [
                            Expanded(
                              child: _buildInsightCard(
                                context,
                                'Avg Moisture',
                                '${avgMoisture.toStringAsFixed(1)}%',
                                'አማካኝ እርጥበት',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInsightCard(
                                context,
                                'Avg Temp',
                                '${avgTemp.toStringAsFixed(1)}°C',
                                'አማካኝ ሙቀት',
                              ),
                            ),
                          ],
                        );
                      },
                    ),

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

  double _calculateAverage(String field) {
    if (_mockData.isEmpty) return 0.0;

    double sum = 0.0;
    for (var data in _mockData) {
      sum += data[field] as double;
    }
    return sum / _mockData.length;
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
