// lib/services/seller_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // <-- TAMBAHAN

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
      // Ambil token dari AuthService
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      // ❗ PENTING: SESUAIKAN path ini dengan mount di backend.
      // Kalau di app.js ada: app.use('/store', storeRouter(con));
      // maka endpoint yang benar adalah: POST /store
      final url = Uri.parse('${ApiConfig.baseUrl}/store');

      print('REGISTER STORE URL   : $url');
      print('REGISTER STORE TOKEN : $token');
      print(
          'REGISTER STORE BODY  : {store_name: $storeName, description: $description, address: $address}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token', // verifyToken pakai ini
            },
            body: jsonEncode({
              'store_name': storeName,
              'description': description,
              'address': address,
            }),
          )
          .timeout(_timeoutDuration);

      print('REGISTER STORE status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('REGISTER STORE body  : $preview');

      // 🔍 Deteksi HTML (endpoint salah / bukan API JSON)
      final contentType = response.headers['content-type'] ?? '';
      final bodyText = response.body.trim();

      final bool looksLikeHtml = bodyText.startsWith('<!DOCTYPE html') ||
          bodyText.startsWith('<html') ||
          contentType.contains('text/html');

      if (looksLikeHtml) {
        return {
          'success': false,
          'message':
              'Server mengembalikan HTML, bukan JSON. Kemungkinan endpoint /store salah mount atau arah ke halaman web lain.\nStatus: ${response.statusCode}',
          'raw_html': bodyText,
        };
      }

      // ✅ Aman decode JSON
      final body = jsonDecode(response.body);

      // Struktur backend yang lu kirim:
      // Sukses: { success: true, message: "...", store_id, owner_id }
      final bool ok = body['success'] == true ||
          response.statusCode == 200 ||
          response.statusCode == 201;

      if (ok) {
        // ⬇️ SET STATUS PENJUAL SECARA LOKAL
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isSeller_local', true);
          print('REGISTER STORE: isSeller_local diset ke TRUE (sukses daftar).');
        } catch (e) {
          print('REGISTER STORE: gagal menyimpan isSeller_local => $e');
        }

        return {
          'success': true,
          'message': body['message'] ?? 'Toko berhasil didaftarkan.',
          'store_id': body['store_id'],
          'owner_id': body['owner_id'],
          'raw': body,
        };
      }

      // ❌ Kalau gagal (misal 403 / 500)
      final String message = body['message'] ??
          'Gagal mendaftar sebagai penjual. (${response.statusCode})';

      bool alreadyHasStore = false;

      // 🎯 DETEKSI KASUS: user sebenarnya SUDAH punya toko
      final lowerMsg = message.toLowerCase();
      if (lowerMsg.contains('hanya diperbolehkan mendaftar satu toko') ||
          lowerMsg.contains('hanya diperbolehkan satu toko') ||
          lowerMsg.contains('sudah memiliki toko')) {
        alreadyHasStore = true;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isSeller_local', true);
          print(
              'REGISTER STORE: pesan backend menandakan user sudah punya toko. isSeller_local = TRUE');
        } catch (e) {
          print(
              'REGISTER STORE: gagal menyimpan isSeller_local (already has store) => $e');
        }
      }

      return {
        'success': false,
        'message': message,
        'raw': body,
        'alreadyHasStore': alreadyHasStore, // info tambahan kalau mau dipakai
      };
    } on TimeoutException catch (e) {
      print('REGISTER STORE TIMEOUT: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout saat mendaftar toko. Coba lagi.',
      };
    } catch (e) {
      print('REGISTER STORE ERROR: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mendaftar toko: $e',
      };
    }
  }
}
