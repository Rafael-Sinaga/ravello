// lib/models/product_model.dart
// Model Product defensif — mendukung berbagai bentuk JSON dari backend.
// Menambahkan field yang diperlukan: productId, storeId, name, description,
// price, discount, imagePath, stock, categoryId, storeName, sizes.

import 'dart:convert';

class Product {
  final dynamic productId; // int or String
  final int? storeId;
  final String name;
  final String description;
  final num price;
  final double? discount;
  final String imagePath;
  final int stock;
  final int? categoryId;
  final String? storeName;
  final List<String>? sizes;

  Product({
    required this.productId,
    this.storeId,
    required this.name,
    required this.description,
    required this.price,
    this.discount,
    required this.imagePath,
    this.stock = 0,
    this.categoryId,
    this.storeName,
    this.sizes,
  });

  // --- Helper parsers ---
  static num _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) {
      final cleaned = v.replaceAll(',', '').trim();
      return num.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      return int.tryParse(v.replaceAll(',', '').trim()) ??
          (num.tryParse(v) ?? 0).toInt();
    }
    return 0;
  }

  static double? _parseDoubleNullable(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.replaceAll(',', '').trim());
    return null;
  }

  /// Parse sizes dari berbagai bentuk:
  /// - List<String> => langsung
  /// - List<Map> => ambil field 'size' / 'name' / 'label'
  /// - String like "S,M,L" => split by comma/semicolon/pipe
  /// - String like '["S","M"]' => jsonDecode dulu
  static List<String>? _parseSizes(dynamic raw) {
    if (raw == null) return null;

    // Jika sudah list
    if (raw is List) {
      try {
        // jika semua elemen string / null
        if (raw.every((e) => e == null || e is String)) {
          return raw
              .map((e) => (e ?? '').toString().trim())
              .where((s) => s.isNotEmpty)
              .cast<String>()
              .toList();
        }

        // kalau elemen berupa map/object => coba ekstrak field umum
        final extracted = <String>[];
        for (final e in raw) {
          if (e == null) continue;
          if (e is String) {
            final s = e.trim();
            if (s.isNotEmpty) extracted.add(s);
            continue;
          }
          if (e is Map) {
            final candidates = ['size', 'name', 'label', 'value', 'ukuran'];
            String? val;
            for (final k in candidates) {
              if (e.containsKey(k) && e[k] != null) {
                val = e[k].toString();
                break;
              }
            }
            if (val != null && val.trim().isNotEmpty) {
              extracted.add(val.trim());
            } else {
              // fallback: ambil first string-like value
              try {
                final firstStringEntry = e.entries.firstWhere(
                  (ent) => ent.value is String,
                  orElse: () => const MapEntry('', ''),
                );
                if (firstStringEntry.value is String &&
                    (firstStringEntry.value as String).trim().isNotEmpty) {
                  extracted.add((firstStringEntry.value as String).trim());
                }
              } catch (_) {
                // ignore
              }
            }
          } else {
            final s = e.toString().trim();
            if (s.isNotEmpty) extracted.add(s);
          }
        }
        return extracted.isEmpty ? null : extracted;
      } catch (_) {
        return null;
      }
    }

    // Jika string
    if (raw is String) {
      final cleaned = raw.trim();
      if (cleaned.isEmpty) return null;

      // 1) Jika string JSON array -> coba decode
      if (cleaned.startsWith('[') && cleaned.endsWith(']')) {
        try {
          final decoded = jsonDecode(cleaned);
          if (decoded is List) {
            return _parseSizes(decoded); // rekursif ke branch List
          }
        } catch (_) {
          // jika gagal decode, fallback ke split biasa di bawah
        }
      }

      // 2) Normalisasi delimiter jadi koma lalu split — hindari regex bermasalah
      final normalized = cleaned.replaceAll('|', ',').replaceAll(';', ',');
      // hapus kutip kalau ada
      final cleanedQuotes = normalized.replaceAll('"', '').replaceAll("'", '');
      final parts = cleanedQuotes
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      return parts.isEmpty ? null : parts;
    }

    // other types: fallback to string
    try {
      final s = raw.toString().trim();
      if (s.isEmpty) return null;
      final normalized = s.replaceAll('|', ',').replaceAll(';', ',');
      final cleanedQuotes = normalized.replaceAll('"', '').replaceAll("'", '');
      final parts = cleanedQuotes
          .split(',')
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      return parts.isEmpty ? [s] : parts;
    } catch (_) {
      return null;
    }
  }

  // --- Factory dari JSON (defensif terhadap berbagai nama field) ---
  factory Product.fromJson(Map<String, dynamic> json) {
    // name: support many keys
    final name = (json['name'] ??
            json['title'] ??
            json['product_name'] ??
            json['nama'] ??
            json['productName'] ??
            '')
        .toString();

    // description: support many keys
    final description = (json['description'] ??
            json['desc'] ??
            json['product_description'] ??
            json['product_desc'] ??
            json['deskripsi'] ??
            json['detail'] ??
            '')
        .toString();

    // image path: support many keys
    final imagePath = (json['imagePath'] ??
            json['image'] ??
            json['image_path'] ??
            json['gambar'] ??
            json['photo'] ??
            json['thumbnail'] ??
            '')
        .toString();

    return Product(
      productId: json['productId'] ??
          json['id'] ??
          json['product_id'] ??
          json['pid'] ??
          json['id_product'],
      storeId: json['storeId'] != null
          ? _parseInt(json['storeId'])
          : (json['store_id'] != null ? _parseInt(json['store_id']) : null),
      name: name,
      description: description,
      price:
          _parseNum(json['price'] ?? json['harga'] ?? json['product_price'] ?? 0),
      discount: _parseDoubleNullable(
          json['discount'] ?? json['diskon'] ?? json['product_discount']),
      imagePath: imagePath,
      stock: _parseInt(
          json['stock'] ?? json['stok'] ?? json['qty'] ?? json['quantity'] ?? 0),
      categoryId: json['categoryId'] != null
          ? _parseInt(json['categoryId'])
          : (json['category_id'] != null ? _parseInt(json['category_id']) : null),
      storeName: (json['storeName'] ??
              json['sellerName'] ??
              json['store_name'] ??
              json['toko'] ??
              json['seller'])
          ?.toString(),
      sizes: _parseSizes(json['sizes'] ??
          json['size'] ??
          json['variants'] ??
          json['variant'] ??
          json['ukuran'] ??
          json['size_list']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'discount': discount,
      'imagePath': imagePath,
      'stock': stock,
      'categoryId': categoryId,
      'storeName': storeName,
      'sizes': sizes,
    };
  }
}
