// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_config.dart';

class UserModel {
  final String name;
  final String email;

  UserModel({required this.name, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: (json['name'] ?? json['fullname'] ?? '') as String,
      email: (json['email'] ?? '') as String,
    );
  }
}

class AuthService {
  static UserModel? currentUser;
  static const _timeoutDuration = Duration(seconds: 15);

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final userData = body['data'] ?? body['user'] ?? body;
        if (userData is Map<String, dynamic>) {
          currentUser = UserModel.fromJson(userData);
        }
        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'message': 'Login gagal (${response.statusCode}): ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        return {
          'success': false,
          'message': 'Registrasi gagal (${response.statusCode}): ${response.body}'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
}
