import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const Duration _timeoutDuration = Duration(seconds: 10);
  static UserModel? currentUser;
  static String? token;

  /// 🔑 LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(_timeoutDuration);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        token = data['token'];

        if (data['user'] != null) {
          currentUser = UserModel.fromJson(data['user']);
        } else {
          currentUser = null;
        }

        print(
            'User berhasil login: ${currentUser?.name}, ${currentUser?.email}');
        print('Token JWT: $token');

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': 'Login gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// 📝 REGISTER
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
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          currentUser = UserModel.fromJson(data['user']);
        }

        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message':
              'Registrasi gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// 🚪 LOGOUT
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey('current_user')) {
        await prefs.remove('current_user');
      }
      if (prefs.containsKey('auth_token')) {
        await prefs.remove('auth_token');
      }

      currentUser = null;
      token = null;

      print('AuthService: logout sukses — data user dihapus.');
    } catch (e) {
      print('AuthService.logout error: $e');
      currentUser = null;
      token = null;
    }
  }
}
