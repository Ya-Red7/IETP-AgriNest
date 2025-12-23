import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import '../core/utils/constants.dart';

class SensorDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Fetch sensor data for the last 30 days
  /// Returns a list of sensor readings
  Future<List<Map<String, dynamic>>> getLast30DaysData() async {
    try {
      // Calculate date 30 days ago
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Try to fetch from Firestore first
      try {
        final querySnapshot = await _db
            .collection('sensorData')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
            .orderBy('timestamp', descending: false)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              'soilMoisture': data['soilMoisture'] ?? 0.0,
              'temperature': data['temperature'] ?? 0.0,
              'humidity': data['humidity'] ?? 0.0,
              'light': data['light'] ?? 0.0,
              'battery': data['battery'] ?? 0.0,
            };
          }).toList();
        }
      } catch (e) {
        // Firestore might not be set up, try API
      }

      // Fallback: Try API endpoint
      try {
        final response = await _dio.get(
          AppConstants.sensorDataEndpoint,
          queryParameters: {
            'days': 30,
            'startDate': thirtyDaysAgo.toIso8601String(),
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final List<dynamic> data = response.data is List
              ? response.data
              : (response.data['data'] as List? ?? []);
          
          return data.map((item) {
            return {
              'timestamp': DateTime.parse(item['timestamp'] ?? DateTime.now().toIso8601String()),
              'soilMoisture': (item['soilMoisture'] ?? item['soil_moisture'] ?? 0.0).toDouble(),
              'temperature': (item['temperature'] ?? 0.0).toDouble(),
              'humidity': (item['humidity'] ?? 0.0).toDouble(),
              'light': (item['light'] ?? item['lux'] ?? 0.0).toDouble(),
              'battery': (item['battery'] ?? item['voltage'] ?? 0.0).toDouble(),
            };
          }).toList();
        }
      } catch (e) {
        // API might not be available
      }

      // If both fail, return empty list or generate sample data for demo
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sensor data: $e');
    }
  }
}
