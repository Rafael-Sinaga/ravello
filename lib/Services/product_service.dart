// lib/services/product_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_config.dart';
import 'auth_service.dart';
import '../models/product_model.dart';

class ProductService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // ============================================================
  // ======================= CREATE PRODUCT =====================
  // ============================================================

  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    XFile? imageFile,
    bool isBoosted = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('storeId');

      if (storeId == null) {
        return {
          'success': false,
          'message': 'Store ID tidak ditemukan. Silakan daftar toko ulang.',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/product');

      http.Response response;

      // =========================
      // TANPA GAMBAR (JSON)
      // =========================
      if (imageFile == null) {
        final payload = <String, dynamic>{
          'product_name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
          'store_id': storeId,
          'is_boosted': isBoosted,
          'is_active': true, // 🔥 WAJIB
        };

        response = await http
            .post(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode(payload),
            )
            .timeout(_timeoutDuration);
      } else {
        // =========================
        // DENGAN GAMBAR (MULTIPART)
        // =========================
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['product_name'] = name;
        request.fields['description'] = description;
        request.fields['price'] = price.toString();
        request.fields['stock'] = stock.toString();
        request.fields['category_id'] = categoryId.toString();
        request.fields['store_id'] = storeId.toString();
        request.fields['is_boosted'] = isBoosted ? '1' : '0';
        request.fields['is_active'] = '1'; // 🔥 WAJIB

        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
          ),
        );

        final streamed =
            await request.send().timeout(_timeoutDuration);
        response = await http.Response.fromStream(streamed);
      }

      final decoded = jsonDecode(response.body);
      final success = decoded is Map && decoded['success'] == true;

      if (!success) {
        return {
          'success': false,
          'message': decoded['message'] ?? 'Gagal menambahkan produk.',
          'raw': decoded,
        };
      }

      return {
        'success': true,
        'message': decoded['message'] ?? 'Produk berhasil ditambahkan.',
        'raw': decoded,
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Koneksi timeout saat menambahkan produk.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menambahkan produk: $e',
      };
    }
  }

  // ============================================================
  // ================= FETCH PRODUK SELLER ======================
  // ============================================================

  static Future<List<Product>> fetchMyProducts() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token tidak tersedia');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/seller/products');

    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        )
        .timeout(_timeoutDuration);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat produk seller');
    }

    final decoded = jsonDecode(response.body);

    final list = decoded is List
        ? decoded
        : decoded['data'] ?? decoded['products'] ?? [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((json) => Product.fromJson(json))
        .toList();
  }

  // ============================================================
  // ======================= FETCH PUBLIC =======================
  // ============================================================

  static Future<List<Product>> fetchProducts() async {
    final response = await http
        .get(Uri.parse('${ApiConfig.baseUrl}/products'))
        .timeout(_timeoutDuration);

    if (response.statusCode != 200) {
      throw Exception('Gagal memuat produk.');
    }

    final decoded = jsonDecode(response.body);
    final list = decoded is List
        ? decoded
        : decoded['products'] ?? decoded['data'] ?? [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => Product.fromJson(e))
        .toList();
  }

  // ============================================================
  // ======================= DELETE PRODUCT =====================
  // ============================================================

  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia.',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/product/$productId');

      final response = await http
          .delete(
            url,
            headers: {
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Produk berhasil dihapus.',
        };
      }

      return {
        'success': false,
        'message': 'Gagal menghapus produk.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
      };
    }
  }
}
