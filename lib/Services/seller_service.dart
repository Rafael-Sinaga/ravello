// lib/services/seller_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_config.dart';
import 'auth_service.dart';

class SellerService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// Daftar toko (membuat store baru untuk client yang sedang login)
  static Future<Map<String, dynamic>> registerStore({
    required String storeName,
    required String description,
    required String address,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/store');

      final response = await http
          .post(
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
          )
          .timeout(_timeoutDuration);

      // Deteksi HTML (endpoint salah)
      final contentType = response.headers['content-type'] ?? '';
      final bodyText = response.body.trim();
      if (bodyText.startsWith('<!DOCTYPE html') ||
          bodyText.startsWith('<html') ||
          contentType.contains('text/html')) {
        return {
          'success': false,
          'message': 'Server mengembalikan HTML, bukan JSON.',
        };
      }

      final body = jsonDecode(response.body);

      final bool ok =
          body['success'] == true ||
          response.statusCode == 200 ||
          response.statusCode == 201;

      if (ok) {
        // 🔥🔥🔥 INI KUNCI PERBAIKAN 🔥🔥🔥
        try {
          final prefs = await SharedPreferences.getInstance();

          // SIMPAN STATUS SELLER
          await prefs.setBool('isSeller_local', true);

          // SIMPAN STORE ID (WAJIB)
          if (body['store_id'] != null) {
            final storeId =
                int.tryParse(body['store_id'].toString());
            if (storeId != null) {
              await prefs.setInt('storeId', storeId);
              print('REGISTER STORE: storeId disimpan => $storeId');
            }
          }
        } catch (e) {
          print('REGISTER STORE: gagal simpan prefs => $e');
        }

        return {
          'success': true,
          'message': body['message'] ?? 'Toko berhasil didaftarkan.',
          'store_id': body['store_id'],
          'owner_id': body['owner_id'],
          'raw': body,
        };
      }

      final message = body['message'] ??
          'Gagal mendaftar sebagai penjual.';

      // Kasus user sudah punya toko
      final lower = message.toLowerCase();
      if (lower.contains('sudah memiliki toko') ||
          lower.contains('hanya diperbolehkan')) {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isSeller_local', true);
        } catch (_) {}
      }

      return {
        'success': false,
        'message': message,
        'raw': body,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi timeout saat mendaftar toko.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
