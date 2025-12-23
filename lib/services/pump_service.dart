import 'package:dio/dio.dart';
import '../core/utils/constants.dart';

class PumpService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Activate the water pump
  /// Returns true if successful, throws exception on failure
  Future<bool> activatePump() async {
    try {
      final response = await _dio.post(
        '/pump/activate',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'action': 'activate',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to activate pump: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timeout. Please check your internet connection.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Unable to connect to server. Please try again later.');
      } else {
        throw Exception('Failed to activate pump: ${e.message}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
