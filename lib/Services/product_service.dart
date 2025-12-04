// lib/services/product_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_config.dart';
import 'auth_service.dart';
import '../models/product_model.dart';

class ProductService {
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// Membuat produk baru untuk toko milik client yang sedang login
  ///
  /// [imageFile] boleh null:
  /// - kalau null  -> kirim JSON biasa (tanpa gambar)
  /// - kalau tidak -> kirim multipart + field "image"
  static Future<Map<String, dynamic>> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    XFile? imageFile,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      // 🔹 Ambil storeId yang disimpan saat daftar toko
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('storeId');
      print('CREATE PRODUCT storeId dari prefs: $storeId');

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
          'category_id: $categoryId, '
          'store_id: $storeId, '
          'hasImage: ${imageFile != null}'
          '}');

      http.Response response;

      // ============================
      // 1) TANPA GAMBAR → JSON BIASA
      // ============================
      if (imageFile == null) {
        final payload = <String, dynamic>{
          'product_name': name,
          'description': description,
          'price': price,
          'stock': stock,
          'category_id': categoryId,
        };

        if (storeId != null) {
          payload['store_id'] = storeId;
        }

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
        // =============================================
        // 2) DENGAN GAMBAR → MULTIPART (AMAN UNTUK WEB)
        // =============================================
        final request = http.MultipartRequest('POST', url);
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['product_name'] = name;
        request.fields['description'] = description;
        request.fields['price'] = price.toString();
        request.fields['stock'] = stock.toString();
        request.fields['category_id'] = categoryId.toString();
        if (storeId != null) {
          request.fields['store_id'] = storeId.toString();
        }

        final bytes = await imageFile.readAsBytes();
        final fileName = imageFile.name;

        request.files.add(
          http.MultipartFile.fromBytes(
            'image', // ⚠️ nama field harus sama dengan upload.single('image')
            bytes,
            filename: fileName,
          ),
        );

        final streamed =
            await request.send().timeout(_timeoutDuration); // kirim
        response = await http.Response.fromStream(streamed);
      }

      print('CREATE PRODUCT status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('CREATE PRODUCT body  : $preview');

      // 🔍 Deteksi kalau server balikin HTML (endpoint salah)
      final contentType = response.headers['content-type'] ?? '';
      final bodyText = response.body.trim();
      final bool looksLikeHtml = bodyText.startsWith('<!DOCTYPE html') ||
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

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('CREATE PRODUCT JSON DECODE ERROR: $e');
        return {
          'success': false,
          'message':
              'Gagal membaca respons server saat menambahkan produk (bukan JSON valid).',
          'raw_body': response.body,
        };
      }

      // ========= LOGIKA SUKSES (lebih longgar) =========
      bool successFlag = false;
      int? productId;
      int? storeIdFromResponse;

      if (decoded is Map<String, dynamic>) {
        // 1) Kalau backend punya field "success", itu yang paling dipercaya
        if (decoded.containsKey('success')) {
          successFlag = decoded['success'] == true;
        } else if (decoded.containsKey('product') ||
            decoded.containsKey('product_id')) {
          // 2) fallback: ada objek produk / product_id
          successFlag = true;
        } else if (response.statusCode == 200 ||
            response.statusCode == 201) {
          // 3) fallback terakhir: status HTTP sukses
          successFlag = true;
        }

        // ambil product_id / store_id kalau ada
        final productObj = decoded['product'];
        if (productObj is Map<String, dynamic>) {
          if (productObj['id'] is int) {
            productId = productObj['id'] as int;
          } else if (productObj['product_id'] is int) {
            productId = productObj['product_id'] as int;
          }
          if (productObj['store_id'] is int) {
            storeIdFromResponse = productObj['store_id'] as int;
          }
        }

        if (decoded['product_id'] is int) {
          productId = decoded['product_id'] as int;
        }
        if (decoded['store_id'] is int) {
          storeIdFromResponse = decoded['store_id'] as int;
        }
      }

      // ❌ Kalau server TIDAK JELAS bilang "success", anggap GAGAL
      if (!successFlag) {
        final msg = (decoded is Map<String, dynamic>)
            ? (decoded['message'] ??
                'Server tidak mengkonfirmasi bahwa produk tersimpan.')
            : 'Server tidak mengkonfirmasi bahwa produk tersimpan.';
        return {
          'success': false,
          'message': '$msg (HTTP ${response.statusCode})',
          'raw': decoded,
        };
      }

      // ⚠️ Kalau suksesFlag true tapi TIDAK ADA product_id → jangan error ke user,
      // cukup log warning biar lu bisa cek di debug.
      if (productId == null) {
        print(
            'WARNING: Server mengembalikan sukses tapi tanpa product_id. Response: $decoded');
      }

      // ✅ Di titik ini kita anggap BERHASIL
      return {
        'success': true,
        'message': (decoded is Map<String, dynamic>)
            ? (decoded['message'] ?? 'Produk berhasil ditambahkan.')
            : 'Produk berhasil ditambahkan.',
        'product_id': productId,
        'store_id': storeIdFromResponse ?? storeId,
        'raw': decoded,
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
      final url = Uri.parse('${ApiConfig.baseUrl}/product');
      final response = await http.get(url).timeout(_timeoutDuration);

      print('FETCH PRODUCTS status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('FETCH PRODUCTS body  : $preview');

      if (response.statusCode != 200) {
        throw Exception('Gagal memuat produk. Status: ${response.statusCode}');
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('FETCH PRODUCTS JSON DECODE ERROR: $e');
        throw Exception('Respons produk bukan JSON valid.');
      }

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
