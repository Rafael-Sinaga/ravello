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
    bool isBoosted = false, // <- flag boost opsional
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
          'is_boosted: $isBoosted, '
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
          'is_boosted': isBoosted,
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
        request.fields['is_boosted'] = isBoosted ? '1' : '0';
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

      // ========= LOGIKA SUKSES (lebih robust) =========
      bool successFlag = false;
      int? productId;
      int? storeIdFromResponse;

      // helper untuk ambil int dari berbagai tipe
      int? _asInt(dynamic v) {
        if (v == null) return null;
        if (v is int) return v;
        if (v is num) return v.toInt();
        return int.tryParse(v.toString());
      }

      if (decoded is Map<String, dynamic>) {
        // 1) Tentukan successFlag: prefer explicit field, fallback ke HTTP code
        if (decoded.containsKey('success')) {
          successFlag = decoded['success'] == true;
        } else if (decoded.containsKey('data')) {
          // kalau ada data, anggap kemungkinan sukses (tapi cek juga kode HTTP)
          successFlag = (response.statusCode == 200 || response.statusCode == 201);
        } else if (decoded.containsKey('product') ||
            decoded.containsKey('product_id') ||
            decoded.containsKey('id')) {
          successFlag = true;
        } else {
          successFlag = (response.statusCode == 200 || response.statusCode == 201);
        }

        // 2) Cek banyak lokasi kemungkinan product id:
        // a) decoded['product'] (objek) atau decoded['data']['product']
        final dynamic productObj = decoded['product'] ?? (decoded['data'] is Map ? decoded['data']['product'] : null);
        if (productObj is Map<String, dynamic>) {
          productId = _asInt(productObj['id'] ?? productObj['product_id'] ?? productObj['insertId']);
          storeIdFromResponse = _asInt(productObj['store_id'] ?? productObj['storeId']);
        }

        // b) decoded['data'] langsung (banyak API pake { data: { id: ... } })
        final dynamic dataObj = decoded['data'];
        if (dataObj is Map<String, dynamic>) {
          productId ??= _asInt(dataObj['id'] ?? dataObj['product_id'] ?? dataObj['insertId']);
          storeIdFromResponse ??= _asInt(dataObj['store_id'] ?? dataObj['storeId']);
        }

        // c) root-level fields
        productId ??= _asInt(decoded['product_id'] ?? decoded['id'] ?? decoded['insertId']);
        storeIdFromResponse ??= _asInt(decoded['store_id'] ?? decoded['storeId']);
      }

      // ❌ Kalau server TIDAK JELAS bilang "success", anggap GAGAL
      if (!successFlag) {
        final msg = (decoded is Map<String, dynamic>)
            ? (decoded['message'] ?? 'Server tidak mengkonfirmasi bahwa produk tersimpan.')
            : 'Server tidak mengkonfirmasi bahwa produk tersimpan.';
        return {
          'success': false,
          'message': '$msg (HTTP ${response.statusCode})',
          'raw': decoded,
        };
      }

      // ⚠️ Kalau suksesFlag true tapi TIDAK ADA product_id → log warning (jangan langsung error)
      if (productId == null) {
        print('WARNING: Server mengembalikan sukses tapi tanpa product_id. Response: $decoded');
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
    final client = http.Client();

    try {
      // Coba beberapa kemungkinan endpoint supaya tetap jalan
      final candidates = <Uri>[
        Uri.parse('${ApiConfig.baseUrl}/product'),
        Uri.parse('${ApiConfig.baseUrl}/products'),
        Uri.parse('${ApiConfig.baseUrl}/api/product'),
        Uri.parse('${ApiConfig.baseUrl}/api/products'),
      ];

      http.Response? successResponse;
      http.Response? lastResponse;

      for (final url in candidates) {
        print('FETCH PRODUCTS try URL: $url');

        final response = await client
            .get(
              url,
              headers: {
                'Accept': 'application/json',
              },
            )
            .timeout(_timeoutDuration);

        print('FETCH PRODUCTS status: ${response.statusCode}');
        final preview = response.body.length > 200
            ? response.body.substring(0, 200)
            : response.body;
        print('FETCH PRODUCTS body  : $preview');

        lastResponse = response;

        if (response.statusCode == 200) {
          successResponse = response;
          break;
        }

        // Kalau 404, coba endpoint berikutnya
        if (response.statusCode == 404) {
          continue;
        }

        // Selain 200/404 anggap error
        throw Exception('Gagal memuat produk. Status: ${response.statusCode}');
      }

      // Tidak ada satu pun endpoint yang kasih 200
      if (successResponse == null) {
        if (lastResponse != null && lastResponse.statusCode == 404) {
          print(
              'FETCH PRODUCTS: semua endpoint 404, kembalikan list kosong (anggap belum ada produk).');
          return <Product>[];
        }
        throw Exception('Gagal memuat produk dari server.');
      }

      // Deteksi kalau server balikin HTML (misroute ke halaman web)
      final bodyText = successResponse.body.trim();
      final contentType = successResponse.headers['content-type'] ?? '';
      final bool looksLikeHtml = bodyText.startsWith('<!DOCTYPE html') ||
          bodyText.startsWith('<html') ||
          contentType.contains('text/html');

      if (looksLikeHtml) {
        print(
            'FETCH PRODUCTS ERROR: server mengembalikan HTML, bukan JSON. Kembalikan list kosong.');
        return <Product>[];
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(successResponse.body);
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
    } finally {
      client.close();
    }
  }

  // ======================= UPDATE PRODUK =======================

  static Future<Map<String, dynamic>> updateProduct({
    required int productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    bool? isBoosted, // <- opsional, supaya nanti bisa ikut diupdate kalau perlu
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
        };
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/product/$productId');

      final bodyMap = <String, dynamic>{
        'product_name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'category_id': categoryId,
      };

      if (isBoosted != null) {
        bodyMap['is_boosted'] = isBoosted;
      }

      final body = jsonEncode(bodyMap);

      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: body,
          )
          .timeout(_timeoutDuration);

      print('UPDATE PRODUCT status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('UPDATE PRODUCT body  : $preview');

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('UPDATE PRODUCT JSON DECODE ERROR: $e');
        return {
          'success': false,
          'message':
              'Gagal membaca respons server saat mengubah produk (bukan JSON valid).',
          'raw_body': response.body,
        };
      }

      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Produk berhasil diperbarui.',
          'raw': decoded,
        };
      }

      return {
        'success': false,
        'message': decoded is Map<String, dynamic>
            ? (decoded['message'] ?? 'Server tidak mengkonfirmasi perubahan produk.')
            : 'Server tidak mengkonfirmasi perubahan produk.',
        'raw': decoded,
      };
    } on TimeoutException catch (e) {
      print('UPDATE PRODUCT TIMEOUT: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout saat mengubah produk. Coba lagi.',
      };
    } catch (e) {
      print('UPDATE PRODUCT ERROR: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat mengubah produk: $e',
      };
    }
  }

  // ======================= HAPUS PRODUK =======================

  static Future<Map<String, dynamic>> deleteProduct(int productId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Token tidak tersedia. Silakan login ulang.',
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

      print('DELETE PRODUCT status: ${response.statusCode}');
      final preview = response.body.length > 200
          ? response.body.substring(0, 200)
          : response.body;
      print('DELETE PRODUCT body  : $preview');

      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (e) {
        print('DELETE PRODUCT JSON DECODE ERROR: $e');
        // Banyak API DELETE balikin body kosong → anggap sukses kalau status 200/204
        if (response.statusCode == 200 || response.statusCode == 204) {
          return {
            'success': true,
            'message': 'Produk berhasil dihapus.',
            'raw_body': response.body,
          };
        }
        return {
          'success': false,
          'message': 'Gagal membaca respons server saat menghapus produk.',
          'raw_body': response.body,
        };
      }

      if (decoded is Map<String, dynamic> && decoded['success'] == true) {
        return {
          'success': true,
          'message': decoded['message'] ?? 'Produk berhasil dihapus.',
          'raw': decoded,
        };
      }

      // fallback kalau backend nggak kirim {success:true}
      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'success': true,
          'message': 'Produk berhasil dihapus.',
          'raw': decoded,
        };
      }

      return {
        'success': false,
        'message': decoded is Map<String, dynamic>
            ? (decoded['message'] ?? 'Server tidak mengkonfirmasi penghapusan produk.')
            : 'Server tidak mengkonfirmasi penghapusan produk.',
        'raw': decoded,
      };
    } on TimeoutException catch (e) {
      print('DELETE PRODUCT TIMEOUT: $e');
      return {
        'success': false,
        'message': 'Koneksi timeout saat menghapus produk. Coba lagi.',
      };
    } catch (e) {
      print('DELETE PRODUCT ERROR: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan saat menghapus produk: $e',
      };
    }
  }
}
