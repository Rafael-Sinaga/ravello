// lib/models/product_model.dart
// Model Product defensif — mendukung berbagai bentuk JSON dari backend.
// FIX: menambahkan dukungan image_url TANPA mengubah UI & logic lain.

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

  // ---------- Helper ----------
  static num _parseNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    final s = v.toString().replaceAll(',', '').trim();
    return num.tryParse(s) ?? 0;
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = v.toString().replaceAll(',', '').trim();
    return int.tryParse(s) ?? 0;
  }

  static double? _parseDoubleNullable(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    final s = v.toString().replaceAll(',', '').trim();
    return double.tryParse(s);
  }

  static List<String>? _parseSizes(dynamic raw) {
    if (raw == null) return null;

    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return null;

      if (s.startsWith('[')) {
        try {
          final decoded = jsonDecode(s);
          if (decoded is List) {
            return decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }

      return s
          .replaceAll('|', ',')
          .replaceAll(';', ',')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return null;
  }

  // ---------- Factory ----------
  factory Product.fromJson(Map<String, dynamic> json) {
   print('PARSE PRODUCT JSON => $json');
    final name = (json['name'] ??
            json['product_name'] ??
            json['title'] ??
            '')
        .toString();

    final description = (json['description'] ??
            json['product_description'] ??
            '')
        .toString();

    // 🔥 FIX UTAMA ADA DI SINI
    final imagePath = (json['imagePath'] ??
            json['image'] ??
            json['image_path'] ??
            json['image_url'] ?? // <--- FIX
            json['thumbnail'] ??
            '')
        .toString();

    return Product(
      productId: json['productId'] ??
          json['id'] ??
          json['product_id'],
      storeId: json['storeId'] != null
          ? _parseInt(json['storeId'])
          : (json['store_id'] != null ? _parseInt(json['store_id']) : null),
      name: name,
      description: description,
      price: _parseNum(json['price']),
      discount: _parseDoubleNullable(json['discount']),
      imagePath: imagePath,
      stock: _parseInt(json['stock']),
      categoryId: json['categoryId'] != null
          ? _parseInt(json['categoryId'])
          : (json['category_id'] != null ? _parseInt(json['category_id']) : null),
      storeName: (json['storeName'] ??
              json['store_name'] ??
              json['seller'])
          ?.toString(),
      sizes: _parseSizes(json['sizes'] ?? json['size']),
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
