// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_config.dart';

class ProductService {
  // ambil token dari SharedPreferences (tanpa AuthService.getToken)
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// POST /product => tambah produk baru
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    int categoryId = 1, // TODO: sesuaikan dengan category_id di DB lu
  }) async {
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan. Silakan login ulang.',
      };
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/product');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'product_name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ??
              'Gagal menambahkan produk (${response.statusCode}).',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan koneksi: $e',
      };
    }
  }
}
