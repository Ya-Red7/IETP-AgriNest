import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'sensor_data_service.dart';

class CsvExportService {
  final SensorDataService _sensorDataService = SensorDataService();

  /// Export 30 days of sensor data to CSV file
  Future<void> export30DaysData() async {
    try {
      // Fetch sensor data
      final sensorData = await _sensorDataService.getLast30DaysData();

      if (sensorData.isEmpty) {
        throw Exception('No sensor data available for the last 30 days');
      }

      // Create CSV content
      final csvData = <List<dynamic>>[
        // Header row
        [
          'Date',
          'Time',
          'Soil Moisture (%)',
          'Temperature (°C)',
          'Humidity (%)',
          'Light (lux)',
          'Battery (V)',
        ],
      ];

      // Add data rows
      for (final reading in sensorData) {
        final timestamp = reading['timestamp'] as DateTime;
        csvData.add([
          _formatDate(timestamp),
          _formatTime(timestamp),
          reading['soilMoisture']?.toStringAsFixed(1) ?? '0.0',
          reading['temperature']?.toStringAsFixed(1) ?? '0.0',
          reading['humidity']?.toStringAsFixed(1) ?? '0.0',
          reading['light']?.toStringAsFixed(0) ?? '0',
          reading['battery']?.toStringAsFixed(2) ?? '0.00',
        ]);
      }

      // Convert to CSV string
      final csvString = const ListToCsvConverter().convert(csvData);

      // Get directory for saving file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.')[0];
      final fileName = 'agrinest_sensor_data_30days_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csvString);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'AgriNest Sensor Data - Last 30 Days',
        subject: 'Sensor Data Export',
      );
    } catch (e) {
      throw Exception('Failed to export CSV: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}
