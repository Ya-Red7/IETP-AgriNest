// Web-specific implementation
// This file is only imported when dart:html is available

import 'dart:html' as html;
import 'dart:convert' show utf8;
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

Future<String> saveCsvFileWeb(List<List<String>> csvData) async {
  // Convert to CSV string
  const converter = ListToCsvConverter();
  final csvString = converter.convert(csvData);

  // Create filename with timestamp
  final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final filename = 'sensor_data_30days_$timestamp.csv';

  // Convert string to bytes
  final bytes = utf8.encode(csvString);
  
  // Create blob and download for web
  final blob = html.Blob([bytes], 'text/csv');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  html.Url.revokeObjectUrl(url);

  debugPrint('[LOG csv_export_service] ========= CSV file download initiated for web: $filename');
  
  return filename;
}

