// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_config.dart';

class AuthService {
  static const Duration _timeoutDuration = Duration(seconds: 10);

  /// Fungsi Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Normalisasi struktur response:
        // 1) jika backend mengembalikan { user: {...}, token: '...' }
        // 2) jika backend mengembalikan user langsung atau menggunakan 'data'
        dynamic user;
        String? token;

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('user')) {
            user = responseData['user'];
          } else if (responseData.containsKey('data')) {
            user = responseData['data'];
          } else {
            // fallback: mungkin responseData sendiri adalah user object
            user = responseData;
          }

          token = responseData['token'] ??
              (responseData['data'] is Map ? responseData['data']['token'] : null);
        } else {
          user = responseData;
        }

        return {
          'success': true,
          'user': user,
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message':
              'Login gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e',
      };
    }
  }

  /// Fungsi Register
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/postClient');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'message':
              'Registrasi gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi: $e',
      };
    }
  }
}
