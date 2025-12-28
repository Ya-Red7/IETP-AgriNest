class ChartDataPoint {
  final DateTime timestamp;
  final double avgSoilMoisture;
  final double avgTemperature;

  ChartDataPoint({
    required this.timestamp,
    required this.avgSoilMoisture,
    required this.avgTemperature,
  });

  /// Create from aggregated data
  factory ChartDataPoint.fromAggregated({
    required DateTime timestamp,
    required double avgSoilMoisture,
    required double avgTemperature,
  }) {
    return ChartDataPoint(
      timestamp: timestamp,
      avgSoilMoisture: avgSoilMoisture,
      avgTemperature: avgTemperature,
    );
  }

  /// Convert to map for chart rendering
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'moisture': avgSoilMoisture,
      'temp': avgTemperature,
    };
  }
}

