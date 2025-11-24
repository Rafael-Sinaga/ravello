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

        // build user safely (server may return different keys)
        final id = data['client_id'] ?? data['id'] ?? 0;
        final name = data['name'] ?? data['user']?['name'] ?? '';
        final mail = data['email'] ?? data['user']?['email'] ?? '';

<<<<<<< HEAD
        currentUser = UserModel(
          id: int.tryParse(id.toString()) ?? 0,
          name: name.toString(),
          email: mail.toString(),
          isSeller: (data['isSeller'] ?? data['user']?['isSeller'] ?? false) == true,
        );

        // Load local saved seller flag (device-side persistence) and apply override if present
        final prefs = await SharedPreferences.getInstance();
        final localSellerStatus = prefs.getBool('isSeller') ?? currentUser!.isSeller;
        currentUser!.isSeller = localSellerStatus;

        print('User berhasil login: ${currentUser?.name}, ${currentUser?.email}');
        print('Token JWT: $token');

        // Optionally save token / user minimal info to SharedPreferences
        await prefs.setString('auth_token', token ?? '');
        await prefs.setString('current_user_name', currentUser?.name ?? '');
        await prefs.setString('current_user_email', currentUser?.email ?? '');
        await prefs.setInt('current_user_id', currentUser?.id ?? 0);

=======
>>>>>>> c88b258086b5aa0d077ae648ab9b8f1529c777c6
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
          'message': 'Registrasi gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// 📩 KIRIM OTP (target = phone string)
  static Future<Map<String, dynamic>> sendOtp(String phone) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/send-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone}),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// ✅ VERIFIKASI OTP (target = phone string)
  static Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/verify-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'phone': phone, 'otp': otp}),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP salah atau kadaluarsa'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// 🚪 LOGOUT
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey('current_user_name')) {
        await prefs.remove('current_user_name');
      }
      if (prefs.containsKey('current_user_email')) {
        await prefs.remove('current_user_email');
      }
      if (prefs.containsKey('current_user_id')) {
        await prefs.remove('current_user_id');
      }
      if (prefs.containsKey('auth_token')) {
        await prefs.remove('auth_token');
      }
      if (prefs.containsKey('isSeller')) {
        await prefs.remove('isSeller');
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

  /// Utility: set seller status in memory + persist
  static Future<void> setSellerStatus(bool status) async {
    if (currentUser != null) {
      currentUser!.isSeller = status;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSeller', status);
    } else {
      // still persist for next login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSeller', status);
    }
  }
}
