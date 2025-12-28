import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ThingSpeakService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.thingspeak.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Get the latest sensor data from ThingSpeak
  /// Returns the most recent feed entry with all fields
  Future<Map<String, dynamic>?> getLatestData() async {
    try {
      // Log API call for debugging
      debugPrint('[LOG thingspeak_service] ========= Fetching latest data from ThingSpeak API...');
      
      final channelId = dotenv.env['CHANNEL_ID'];
      final readKey = dotenv.env['READ_API_KEY'];

      // Always null-check - CRITICAL
      if (channelId == null || readKey == null) {
        throw Exception('Missing ThingSpeak env config');
      }

      final response = await _dio.get(
        '/channels/$channelId/feeds.json',
        queryParameters: {
          'results': 1, // Get only the latest entry
          'api_key': readKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final feeds = data['feeds'] as List<dynamic>?;

        if (feeds != null && feeds.isNotEmpty) {
          final latestFeed = feeds.first as Map<String, dynamic>;
          debugPrint('[LOG thingspeak_service] ========= Successfully fetched latest data from ThingSpeak');
          // Return the latest feed entry
          return latestFeed;
        }
      }

      debugPrint('[LOG thingspeak_service] ========= No data found in ThingSpeak response');
      return null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to ThingSpeak API. Please try again later.');
      } else if (e.response != null) {
        throw Exception('ThingSpeak API error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to fetch data: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get historical data from ThingSpeak
  /// Returns list of feed entries with all fields
  /// [results] - Number of entries to fetch (max 8000 for free plan)
  Future<List<Map<String, dynamic>>> getHistoricalData({required int results}) async {
    try {
      debugPrint('[LOG thingspeak_service] ========= Fetching historical data (results: $results)...');
      
      final channelId = dotenv.env['CHANNEL_ID'];
      final readKey = dotenv.env['READ_API_KEY'];

      // Always null-check - CRITICAL
      if (channelId == null || readKey == null) {
        throw Exception('Missing ThingSpeak env config');
      }

      // Limit results to 8000 (ThingSpeak free plan limit)
      final limitedResults = results > 8000 ? 8000 : results;

      final response = await _dio.get(
        '/channels/$channelId/feeds.json',
        queryParameters: {
          'results': limitedResults,
          'api_key': readKey,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final feeds = data['feeds'] as List<dynamic>?;

        if (feeds != null && feeds.isNotEmpty) {
          debugPrint('[LOG thingspeak_service] ========= Successfully fetched ${feeds.length} historical entries');
          return feeds.map((feed) => feed as Map<String, dynamic>).toList();
        }
      }

      debugPrint('[LOG thingspeak_service] ========= No historical data found');
      return [];
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to ThingSpeak API. Please try again later.');
      } else if (e.response != null) {
        throw Exception('ThingSpeak API error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to fetch data: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Update pump state using ThingSpeak WRITE API
  /// [isOn] - true to turn pump ON (field8=1), false to turn OFF (field8=0)
  /// Returns true if successful, throws exception on failure
  Future<bool> updatePumpState(bool isOn) async {
    try {
      debugPrint('[LOG thingspeak_service] ========= Updating pump state to: ${isOn ? "ON" : "OFF"}');
      
      final writeKey = dotenv.env['WRITE_API_KEY'];

      // Always null-check - CRITICAL
      if (writeKey == null) {
        throw Exception('Missing ThingSpeak WRITE_API_KEY in env config');
      }

      final field8Value = isOn ? 1 : 0;

      final response = await _dio.get(
        '/update',
        queryParameters: {
          'api_key': writeKey,
          'field8': field8Value,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // ThingSpeak returns entry ID as either int or string
        int? entryId;
        if (response.data is int) {
          entryId = response.data as int;
        } else if (response.data is String) {
          entryId = int.tryParse(response.data as String);
        } else {
          // Try to parse as string first, then convert
          final dataStr = response.data.toString();
          entryId = int.tryParse(dataStr);
        }
        
        if (entryId != null && entryId > 0) {
          debugPrint('[LOG thingspeak_service] ========= Successfully updated pump state. Entry ID: $entryId');
          return true;
        } else {
          throw Exception('ThingSpeak returned invalid entry ID: ${response.data}');
        }
      }

      throw Exception('ThingSpeak API returned unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to ThingSpeak API. Please try again later.');
      } else if (e.response != null) {
        final statusCode = e.response?.statusCode;
        if (statusCode == 429) {
          throw Exception('Rate limit exceeded. Please wait 15 seconds before trying again.');
        }
        throw Exception('ThingSpeak API error: $statusCode - ${e.response?.statusMessage}');
      } else {
        throw Exception('Failed to update pump state: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

