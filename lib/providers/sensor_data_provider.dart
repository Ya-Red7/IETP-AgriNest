import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sensor_data.dart';
import '../services/thingspeak_service.dart';

final thingSpeakServiceProvider = Provider<ThingSpeakService>((ref) {
  return ThingSpeakService();
});

final sensorDataProvider = FutureProvider<SensorData?>((ref) async {
  final service = ref.read(thingSpeakServiceProvider);
  
  try {
    debugPrint('[LOG sensor_data_provider] ========= Starting sensor data fetch...');
    final feedData = await service.getLatestData();
    
    if (feedData == null) {
      debugPrint('[LOG sensor_data_provider] ========= No feed data received from API');
      return null;
    }
    
    final sensorData = SensorData.fromThingSpeak(feedData);
    debugPrint('[LOG sensor_data_provider] ========= Sensor data successfully parsed and updated');
    return sensorData;
  } catch (e) {
    // Log error but don't crash the app
    debugPrint('[LOG sensor_data_provider] ========= Error fetching sensor data: $e');
    rethrow;
  }
});

