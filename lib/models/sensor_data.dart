class SensorData {
  final double? soilMoisture; // field1
  final double? temperature; // field2
  final double? humidity; // field3
  final double? light; // field4
  final bool pumpStatus; // field5 (1 = ON, 0/null/other = OFF) - Arduino status
  final double? battery; // field6
  final bool manualPumpControl; // field8 (1 = ON, 0/null/other = OFF) - Manual control
  final String soilStatus; // Calculated on client side

  SensorData({
    this.soilMoisture,
    this.temperature,
    this.humidity,
    this.light,
    this.pumpStatus = false, // Default to OFF
    this.battery,
    this.manualPumpControl = false, // Default to OFF
    String? soilStatus,
  }) : soilStatus = soilStatus ?? _calculateSoilStatus(soilMoisture);

  /// Calculate soil status based on moisture percentage
  /// < 30% → "Dry"
  /// 30–70% → "Optimal"
  /// > 70% → "Wet"
  static String _calculateSoilStatus(double? moisture) {
    if (moisture == null) return 'Unknown';
    
    if (moisture < 30) {
      return 'Dry';
    } else if (moisture >= 30 && moisture <= 70) {
      return 'Optimal';
    } else {
      return 'Wet';
    }
  }

  /// Create SensorData from ThingSpeak API response
  factory SensorData.fromThingSpeak(Map<String, dynamic> feed) {
    // Safely parse field values, handling null or invalid data
    double? parseField(String? value) {
      if (value == null || value.isEmpty) return null;
      try {
        return double.tryParse(value);
      } catch (e) {
        return null;
      }
    }

    // Parse pump status (field5) - 1 = ON, 0/null/other = OFF
    bool parsePumpStatus(String? value) {
      if (value == null || value.isEmpty) return false;
      try {
        // Try parsing as number
        final numValue = double.tryParse(value);
        if (numValue != null) {
          // Only 1 = ON, everything else (0, null, other) = OFF
          return numValue == 1;
        }
        // Try parsing as string "1" or "0"
        final trimmedValue = value.trim();
        return trimmedValue == '1';
      } catch (e) {
        // Any error or invalid value = OFF
        return false;
      }
    }

    final soilMoisture = parseField(feed['field1'] as String?);
    final temperature = parseField(feed['field2'] as String?);
    final humidity = parseField(feed['field3'] as String?);
    final light = parseField(feed['field4'] as String?);
    final pumpStatus = parsePumpStatus(feed['field5'] as String?); // field5 = Pump Status (Arduino)
    final battery = parseField(feed['field6'] as String?); // field6 = Battery
    final manualPumpControl = parsePumpStatus(feed['field8'] as String?); // field8 = Manual Pump Control

    return SensorData(
      soilMoisture: soilMoisture,
      temperature: temperature,
      humidity: humidity,
      light: light,
      pumpStatus: pumpStatus,
      battery: battery,
      manualPumpControl: manualPumpControl,
    );
  }

  /// Create a copy with updated values
  SensorData copyWith({
    double? soilMoisture,
    double? temperature,
    double? humidity,
    double? light,
    bool? pumpStatus,
    double? battery,
    bool? manualPumpControl,
    String? soilStatus,
  }) {
    return SensorData(
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      light: light ?? this.light,
      pumpStatus: pumpStatus ?? this.pumpStatus,
      battery: battery ?? this.battery,
      manualPumpControl: manualPumpControl ?? this.manualPumpControl,
      soilStatus: soilStatus ?? this.soilStatus,
    );
  }

  /// Check if all sensor values are null
  bool get isEmpty {
    return soilMoisture == null &&
        temperature == null &&
        humidity == null &&
        light == null &&
        battery == null;
  }
}

