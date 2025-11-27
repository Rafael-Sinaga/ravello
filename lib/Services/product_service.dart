// lib/services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  /// POST /product — tambah produk baru
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/product');

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
          'message': data['message'] ?? 'Produk berhasil ditambahkan.',
          'product_id': data['product_id'],
          'store_id': data['store_id'],
        };
      } else {
        return {
          'success': false,
          'message':
              data['message'] ?? 'Gagal menambahkan produk (${response.statusCode}).',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan koneksi: $e',
      };
    }
  }

  /// GET /product — ambil semua produk (asumsi route GET sudah ada)
  static Future<List<Product>> fetchProducts() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/product');
      final response = await http.get(url);

      if (response.statusCode != 200) {
        print(
            'fetchProducts gagal: ${response.statusCode} ${response.body}');
        return [];
      }

      final body = jsonDecode(response.body);

      // fleksibel: backend bisa kirim langsung list, atau bungkus dalam field.
      List<dynamic> listJson;

      if (body is List) {
        listJson = body;
      } else if (body is Map<String, dynamic>) {
        if (body['products'] is List) {
          listJson = body['products'];
        } else if (body['data'] is List) {
          listJson = body['data'];
        } else {
          print('fetchProducts: format JSON tidak dikenal: $body');
          return [];
        }
      } else {
        print('fetchProducts: response bukan list/map');
        return [];
      }

      return listJson
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('fetchProducts error: $e');
      return [];
    }
  }
}
