// lib/services/product_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/api_config.dart';
import 'auth_service.dart';
import '../models/product_model.dart';

class ProductService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// Membuat produk baru untuk toko milik client yang sedang login
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      // ❗ SESUAIKAN dengan mount router di backend:
      // misal: app.use('/product', productRouter(con));
      final url = Uri.parse('${ApiConfig.baseUrl}/product');

      print('CREATE PRODUCT URL   : $url');
      print('CREATE PRODUCT TOKEN : $token');
      print('CREATE PRODUCT BODY  : {'
          'product_name: $name, '
          'description: $description, '
          'price: $price, '
          'stock: $stock, '
          'category_id: $categoryId'
          '}');

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              // ⚠️ WAJIB sama persis dengan backend
              'product_name': name,
              'description': description,
              'price': price,
              'stock': stock,
              'category_id': categoryId,
            }),
          )
          .timeout(_timeoutDuration);

      print('CREATE PRODUCT status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('CREATE PRODUCT body  : $preview');

      // Deteksi kalau server balikin HTML (endpoint salah)
      final contentType = response.headers['content-type'] ?? '';
      final bodyText = response.body.trim();
      final bool looksLikeHtml =
          bodyText.startsWith('<!DOCTYPE html') ||
              bodyText.startsWith('<html') ||
              contentType.contains('text/html');

      if (looksLikeHtml) {
        return {
          'success': false,
          'message':
              'Server mengembalikan HTML, bukan JSON. Kemungkinan endpoint /product salah atau mengarah ke halaman web.\nStatus: ${response.statusCode}',
          'raw_html': bodyText,
        };
      }

      final body = jsonDecode(response.body);

      // Backend lu kirim: { success: true, message, product_id, store_id }
      final bool ok = body['success'] == true ||
          response.statusCode == 200 ||
          response.statusCode == 201;

      if (ok) {
        return {
          'success': true,
          'message': body['message'] ?? 'Produk berhasil ditambahkan.',
          'product_id': body['product_id'],
          'store_id': body['store_id'],
          'raw': body,
        };
      }

      return {
        'success': false,
        'message': body['message'] ??
            'Gagal menambahkan produk. (${response.statusCode})',
        'raw': body,
      };
    } on TimeoutException catch (e) {
      print('CREATE PRODUCT TIMEOUT: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout saat menambahkan produk. Coba lagi.',
      };
    } catch (e) {
      print('CREATE PRODUCT ERROR: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menambahkan produk: $e',
      };
    }
  }

  /// Ambil semua produk untuk ditampilkan di beranda
  static Future<List<Product>> fetchProducts() async {
    try {
      // kalau endpoint publik tanpa auth:
      final url = Uri.parse('${ApiConfig.baseUrl}/product');
      final response = await http.get(url).timeout(_timeoutDuration);

      print('FETCH PRODUCTS status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('FETCH PRODUCTS body  : $preview');

      if (response.statusCode != 200) {
        throw Exception(
            'Gagal memuat produk. Status: ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      // Bisa berupa: List, atau { data: [...] }, atau { products: [...] }
      List<dynamic> rawList;
      if (decoded is List) {
        rawList = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is List) {
          rawList = decoded['data'] as List<dynamic>;
        } else if (decoded['products'] is List) {
          rawList = decoded['products'] as List<dynamic>;
        } else {
          rawList = [];
        }
      } else {
        rawList = [];
      }

      // Map ke model Product (pastikan Product.fromJson ada)
      final products = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => Product.fromJson(json))
          .toList();

      return products;
    } on TimeoutException catch (e) {
      print('FETCH PRODUCTS TIMEOUT: $e');
      throw Exception('Koneksi timeout saat memuat produk.');
    } catch (e) {
      print('FETCH PRODUCTS ERROR: $e');
      rethrow;
    }
  }
}
