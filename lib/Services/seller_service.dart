import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class SellerService {
  // Ganti IP/port sesuai backend lu
  static const String baseUrl = 'http://10.38.48.140:3000';

  static Future<Map<String, dynamic>> registerStore({
    required String storeName,
    required String description,
    required String address,
  }) async {
    // Ambil token: prioritaskan yang di AuthService, fallback ke SharedPreferences
    String? token = AuthService.token;

    if (token == null || token.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString('auth_token');
    }

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Token tidak tersedia. Silakan login ulang.',
      };
    }

    final uri = Uri.parse('$baseUrl/store'); // sesuaikan dengan route backend

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'store_name': storeName,
          'description': description,
          'address': address,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Toko berhasil didaftarkan.',
          'store_id': data['store_id'],
          'owner_id': data['owner_id'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal membuat toko. (${response.statusCode})',
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
