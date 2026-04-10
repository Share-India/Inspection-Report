import 'package:dio/dio.dart';
import 'package:policysquare/api/api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          final messages = data.entries.map((e) => '\${e.key}: \${e.value}').join('\\n');
          throw Exception(messages.isNotEmpty ? messages : 'Login failed');
        }
        throw Exception(data.toString());
      } else {
        throw Exception('Network error during login. Details: \${e.error} (Message: \${e.message})');
      }
    }
  }

  Future<Map<String, dynamic>> signup(String username, String email, String mobile, String password) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/auth/signup',
        data: {
          'username': username,
          'email': email,
          'mobileNumber': mobile,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          final messages = data.entries.map((e) => '\${e.key}: \${e.value}').join('\\n');
          throw Exception(messages.isNotEmpty ? messages : 'Signup failed');
        }
        throw Exception(data.toString());
      } else {
        throw Exception('Network error during signup. Details: \${e.error} (Message: \${e.message})');
      }
    }
  }
}
