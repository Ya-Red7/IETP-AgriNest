import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'dart:convert' show utf8;
import 'thingspeak_service.dart';
import 'csv_export_web_stub.dart' if (dart.library.html) 'csv_export_web.dart' as web_export;

class CsvExportService {
  final ThingSpeakService _thingSpeakService;

  CsvExportService(this._thingSpeakService);

  /// Export past 30 days of sensor data to CSV
  /// Returns the file path (or filename for web) if successful, throws exception on failure
  Future<String> export30DaysData() async {
    try {
      debugPrint('[LOG csv_export_service] ========= Starting CSV export for 30 days data...');
      
      // Fetch 30 days of data (8000 entries max for ThingSpeak free plan)
      final feeds = await _thingSpeakService.getHistoricalData(results: 8000);
      
      if (feeds.isEmpty) {
        throw Exception('No data available to export');
      }

      debugPrint('[LOG csv_export_service] ========= Fetched ${feeds.length} entries, converting to CSV...');

      // Convert to CSV format
      final csvData = _convertToCsv(feeds);
      
      // Handle web and mobile platforms differently
      if (kIsWeb) {
        return await _saveToFileWeb(csvData);
      } else {
        return await _saveToFileMobile(csvData);
      }
    } catch (e) {
      debugPrint('[LOG csv_export_service] ========= Error exporting CSV: $e');
      rethrow;
    }
  }

  /// Convert ThingSpeak feeds to CSV format
  List<List<String>> _convertToCsv(List<Map<String, dynamic>> feeds) {
    final csvData = <List<String>>[];
    
    // CSV Header
    csvData.add([
      'Timestamp',
      'Date',
      'Time',
      'Soil Moisture (%)',
      'Temperature (°C)',
      'Humidity (%)',
      'Light',
      'Battery (%)',
      'Pump Status',
      'Manual Pump Control',
    ]);

    // Date formatters
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final timeFormatter = DateFormat('HH:mm:ss');

    // Convert each feed entry to CSV row
    for (final feed in feeds) {
      // Parse timestamp
      final createdAt = feed['created_at'] as String?;
      DateTime? timestamp;
      if (createdAt != null) {
        try {
          timestamp = DateTime.parse(createdAt);
        } catch (e) {
          debugPrint('[LOG csv_export_service] ========= Error parsing timestamp: $createdAt');
        }
      }

      // Parse field values
      final soilMoisture = _parseField(feed['field1']);
      final temperature = _parseField(feed['field2']);
      final humidity = _parseField(feed['field3']);
      final light = _parseField(feed['field4']);
      final pumpStatus = _parsePumpStatus(feed['field5']);
      final battery = _parseField(feed['field6']);
      final manualPumpControl = _parsePumpStatus(feed['field8']);

      // Format timestamp
      final dateStr = timestamp != null ? dateFormatter.format(timestamp) : '';
      final timeStr = timestamp != null ? timeFormatter.format(timestamp) : '';
      final timestampStr = timestamp != null ? timestamp.toIso8601String() : '';

      // Add row to CSV
      csvData.add([
        timestampStr,
        dateStr,
        timeStr,
        soilMoisture ?? '',
        temperature ?? '',
        humidity ?? '',
        light ?? '',
        battery ?? '',
        pumpStatus ? 'ON' : 'OFF',
        manualPumpControl ? 'ON' : 'OFF',
      ]);
    }

    return csvData;
  }

  /// Parse field value to string
  String? _parseField(dynamic value) {
    if (value == null || value == '') return null;
    try {
      final parsed = double.tryParse(value.toString());
      return parsed?.toStringAsFixed(2);
    } catch (e) {
      return null;
    }
  }

  /// Parse pump status field
  bool _parsePumpStatus(dynamic value) {
    if (value == null || value == '') return false;
    try {
      final numValue = double.tryParse(value.toString());
      return numValue == 1;
    } catch (e) {
      return value.toString().trim() == '1';
    }
  }

  /// Save CSV data for mobile platforms
  Future<String> _saveToFileMobile(List<List<String>> csvData) async {
    // Convert to CSV string
    const converter = ListToCsvConverter();
    final csvString = converter.convert(csvData);

    // Create filename with timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final filename = 'AgriNest_sensor_data_30days_$timestamp.csv';

    // Convert to bytes
    final bytes = utf8.encode(csvString);
    
    // Use share_plus to save/share the file
    final xFile = XFile.fromData(
      bytes,
      mimeType: 'text/csv',
      name: filename,
    );
    
    await Share.shareXFiles([xFile], text: 'Sensor Data Export - Past 30 Days');
    
    debugPrint('[LOG csv_export_service] ========= CSV file shared successfully: $filename');
    
    return filename;
  }

  /// Save CSV data for web platform (returns filename)
  Future<String> _saveToFileWeb(List<List<String>> csvData) async {
    return await web_export.saveCsvFileWeb(csvData);
  }

  /// Share the CSV file
  Future<void> shareCsvFile(String filePathOrName) async {
    try {
      debugPrint('[LOG csv_export_service] ========= Sharing CSV file: $filePathOrName');
      
      if (kIsWeb) {
        // For web, the file is already downloaded, just show success
        debugPrint('[LOG csv_export_service] ========= CSV file download completed for web');
        return;
      }
      
      // For mobile platforms, file is already shared in _saveToFileMobile
      debugPrint('[LOG csv_export_service] ========= CSV file already shared');
    } catch (e) {
      debugPrint('[LOG csv_export_service] ========= Error sharing CSV file: $e');
      rethrow;
    }
  }
}
