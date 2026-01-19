import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_config.dart';
import 'auth_service.dart';

class SellerService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// ================== REGISTER STORE ==================
  static Future<Map<String, dynamic>> registerStore({
    required String storeName,
    required String description,
    required String address,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Session expired. Login ulang.'
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/store');

      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'store_name': storeName,
          'description': description,
          'address': address,
        }),
      ).timeout(_timeoutDuration);

      final body = jsonDecode(res.body);

      if (res.statusCode != 201 || body['success'] != true) {
        return {
          'success': false,
          'message': body['message'] ?? 'Gagal daftar toko'
        };
      }

      await AuthService.logout();

      return {
        'success': true,
        'force_logout': true,
        'message': 'Toko berhasil dibuat. Silakan login ulang.'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e'
      };
    }
  }

  /// ================== GET STORE DETAIL ==================
  /// Update: Menggunakan endpoint /profile agar otomatis mengambil ID dari Token JWT
  static Future<Map<String, dynamic>> getStoreDetail() async {
    try {
      // 1. Ambil token terbaru dari AuthService
      final token = await AuthService.getToken();

      // 2. GANTI URL: Gunakan /store/profile (Tanpa parameter ID manual)
      // Karena Backend sekarang sudah membaca ID dari Token
      final url = Uri.parse('${ApiConfig.baseUrl}/store/profile'); 

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 👈 WAJIB: Token dikirim di sini
        },
      ).timeout(_timeoutDuration);

      return jsonDecode(response.body);
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil detail toko',
        'error': e.toString(),
      };
    }
  }
}