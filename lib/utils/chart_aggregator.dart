import '../models/chart_data.dart';

class ChartAggregator {
  /// Aggregate data for 24 hours (hourly averages)
  /// Returns exactly 24 data points
  static List<ChartDataPoint> aggregateHourly(List<Map<String, dynamic>> feeds) {
    if (feeds.isEmpty) return [];

    // Parse and filter valid entries
    final validFeeds = <Map<String, dynamic>>[];
    for (final feed in feeds) {
      final field1 = feed['field1'] as String?;
      final field2 = feed['field2'] as String?;
      final createdAt = feed['created_at'] as String?;

      if (field1 != null && field2 != null && createdAt != null) {
        final moisture = double.tryParse(field1);
        final temperature = double.tryParse(field2);

        if (moisture != null && temperature != null) {
          validFeeds.add({
            'timestamp': DateTime.parse(createdAt).toLocal(),
            'moisture': moisture,
            'temperature': temperature,
          });
        }
      }
    }

    if (validFeeds.isEmpty) return [];

    // Use current device time as reference point
    final now = DateTime.now();
    // Round current time to the current hour
    final currentHour = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    );
    final startTime = currentHour.subtract(const Duration(hours: 23));

    // Group by hour
    final hourlyData = <String, List<Map<String, dynamic>>>{};
    for (final feed in validFeeds) {
      final timestamp = feed['timestamp'] as DateTime;
      if (timestamp.isBefore(startTime)) continue;

      // Round down to the hour
      final hourKey = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
        timestamp.hour,
      );

      final key = hourKey.toIso8601String();
      hourlyData.putIfAbsent(key, () => []).add(feed);
    }

    // Generate 24 hourly buckets from "now - 23 hours" to "now" (current hour)
    final result = <ChartDataPoint>[];
    for (int i = 23; i >= 0; i--) {
      final targetHour = currentHour.subtract(Duration(hours: i));
      final hourKey = DateTime(
        targetHour.year,
        targetHour.month,
        targetHour.day,
        targetHour.hour,
      );
      final key = hourKey.toIso8601String();

      final bucketData = hourlyData[key] ?? [];
      if (bucketData.isNotEmpty) {
        final avgMoisture = bucketData.map((f) => f['moisture'] as double).reduce((a, b) => a + b) / bucketData.length;
        final avgTemp = bucketData.map((f) => f['temperature'] as double).reduce((a, b) => a + b) / bucketData.length;

        result.add(ChartDataPoint.fromAggregated(
          timestamp: hourKey,
          avgSoilMoisture: avgMoisture,
          avgTemperature: avgTemp,
        ));
      } else {
        // Use previous value or 0 if no data
        final prevValue = result.isNotEmpty ? result.last : null;
        result.add(ChartDataPoint.fromAggregated(
          timestamp: hourKey,
          avgSoilMoisture: prevValue?.avgSoilMoisture ?? 0.0,
          avgTemperature: prevValue?.avgTemperature ?? 0.0,
        ));
      }
    }

    return result;
  }

  /// Aggregate data for days (daily averages)
  /// Returns exactly [days] data points
  static List<ChartDataPoint> aggregateDaily(List<Map<String, dynamic>> feeds, int days) {
    if (feeds.isEmpty) return [];

    // Parse and filter valid entries
    final validFeeds = <Map<String, dynamic>>[];
    for (final feed in feeds) {
      final field1 = feed['field1'] as String?;
      final field2 = feed['field2'] as String?;
      final createdAt = feed['created_at'] as String?;

      if (field1 != null && field2 != null && createdAt != null) {
        final moisture = double.tryParse(field1);
        final temperature = double.tryParse(field2);

        if (moisture != null && temperature != null) {
          validFeeds.add({
            'timestamp': DateTime.parse(createdAt).toLocal(),
            'moisture': moisture,
            'temperature': temperature,
          });
        }
      }
    }

    if (validFeeds.isEmpty) return [];

    // Use current device time rounded to today's midnight as reference point
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startTime = today.subtract(Duration(days: days - 1));
    final tomorrow = today.add(const Duration(days: 1)); // Start of tomorrow (end of today)

    // Group by day
    final dailyData = <String, List<Map<String, dynamic>>>{};
    for (final feed in validFeeds) {
      final timestamp = feed['timestamp'] as DateTime;
      // Include data from startTime (inclusive) up to end of today (before tomorrow)
      // This means: startTime <= timestamp < tomorrow
      if (timestamp.isBefore(startTime) || timestamp.isAtSameMomentAs(tomorrow) || timestamp.isAfter(tomorrow)) continue;

      // Round down to the day (midnight)
      final dayKey = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );

      final key = dayKey.toIso8601String();
      dailyData.putIfAbsent(key, () => []).add(feed);
    }

    // Generate N daily buckets from "today - (days-1)" to "today" (inclusive)
    final result = <ChartDataPoint>[];
    for (int i = days - 1; i >= 0; i--) {
      final targetDay = today.subtract(Duration(days: i));
      final dayKey = DateTime(
        targetDay.year,
        targetDay.month,
        targetDay.day,
      );
      final key = dayKey.toIso8601String();

      final bucketData = dailyData[key] ?? [];
      if (bucketData.isNotEmpty) {
        final avgMoisture = bucketData.map((f) => f['moisture'] as double).reduce((a, b) => a + b) / bucketData.length;
        final avgTemp = bucketData.map((f) => f['temperature'] as double).reduce((a, b) => a + b) / bucketData.length;

        result.add(ChartDataPoint.fromAggregated(
          timestamp: dayKey,
          avgSoilMoisture: avgMoisture,
          avgTemperature: avgTemp,
        ));
      } else {
        // Use previous value or 0 if no data
        final prevValue = result.isNotEmpty ? result.last : null;
        result.add(ChartDataPoint.fromAggregated(
          timestamp: dayKey,
          avgSoilMoisture: prevValue?.avgSoilMoisture ?? 0.0,
          avgTemperature: prevValue?.avgTemperature ?? 0.0,
        ));
      }
    }

    return result;
  }
}

