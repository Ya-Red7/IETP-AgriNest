import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chart_data.dart';
import '../services/thingspeak_service.dart';
import '../utils/chart_aggregator.dart';

final chartDataServiceProvider = Provider<ThingSpeakService>((ref) {
  return ThingSpeakService();
});

// Cache for each period
final chartData24hProvider = FutureProvider<List<ChartDataPoint>>((ref) async {
  return _fetchChartData(ref, '24h');
});

final chartData7dProvider = FutureProvider<List<ChartDataPoint>>((ref) async {
  return _fetchChartData(ref, '7days');
});

final chartData30dProvider = FutureProvider<List<ChartDataPoint>>((ref) async {
  return _fetchChartData(ref, '30days');
});

Future<List<ChartDataPoint>> _fetchChartData(Ref ref, String period) async {
  final service = ref.read(chartDataServiceProvider);
  
  try {
    debugPrint('[LOG chart_data_provider] ========= Fetching chart data for period: $period');
    
    // Calculate required results based on period
    // Arduino uploads every 20 seconds
    int results;
    switch (period) {
      case '24h':
        // 24 hours * 60 minutes * 3 entries per minute = 4320
        results = 4320;
        break;
      case '7days':
        // 7 days * 24 hours * 60 minutes * 3 = 30240
        results = 30240;
        break;
      case '30days':
        // 30 days * 24 hours * 60 minutes * 3 = 129600 (but limit to 8000)
        results = 8000; // ThingSpeak free plan limit
        break;
      default:
        results = 4320;
    }

    final feeds = await service.getHistoricalData(results: results);
    
    if (feeds.isEmpty) {
      debugPrint('[LOG chart_data_provider] ========= No data received for period: $period');
      return [];
    }

    // Aggregate based on period
    List<ChartDataPoint> aggregated;
    switch (period) {
      case '24h':
        aggregated = ChartAggregator.aggregateHourly(feeds);
        break;
      case '7days':
        aggregated = ChartAggregator.aggregateDaily(feeds, 7);
        break;
      case '30days':
        aggregated = ChartAggregator.aggregateDaily(feeds, 30);
        break;
      default:
        aggregated = [];
    }

    debugPrint('[LOG chart_data_provider] ========= Aggregated ${aggregated.length} data points for period: $period');
    return aggregated;
  } catch (e) {
    debugPrint('[LOG chart_data_provider] ========= Error fetching chart data for $period: $e');
    rethrow;
  }
}

