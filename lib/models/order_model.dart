// lib/models/order_model.dart
// Model order defensif — bisa dipakai untuk komunikasi dengan backend (BackendOrder)
// dan juga sebagai model aplikasi (AppOrder) yang dipakai OrderProvider / UI.
import 'app_order.dart';
import 'dart:convert';
import 'order_item.dart';
import 'product_model.dart';
import 'app_order.dart'; // ini ada OrderStatus

/// Status order yang dipakai di UI / provider.
/// Nama enum disesuaikan dengan yang sering dipakai di codebase:
/// - belumBayar, diproses, dikirim, diterima, selesai
/*enum OrderStatus {
  belumBayar,
  diproses,
  dikirim,
  diterima,
  selesai,
} */

/// Parser helper: ubah string/number date ke DateTime dengan fallback.
DateTime _parseDate(dynamic v) {
  if (v == null) return DateTime.now();
  if (v is DateTime) return v;
  final s = v.toString().trim();
  if (s.isEmpty) return DateTime.now();

  // coba beberapa format umum
  try {
    return DateTime.parse(s);
  } catch (_) {
    // coba deteksi timestamp (ms / s)
    final n = int.tryParse(s);
    if (n != null) {
      // kalo terlalu panjang assume milliseconds
      if (s.length > 10) {
        return DateTime.fromMillisecondsSinceEpoch(n);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(n * 1000);
      }
    }
  }
  return DateTime.now();
}

/// Parser helper: num safe
num _parseNum(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v;
  final s = v.toString().replaceAll(',', '').trim();
  return num.tryParse(s) ?? 0;
}

/// Parser helper: int safe
int _parseInt(dynamic v) {
  final n = _parseNum(v);
  return n.toInt();
}

/// Parser helper: map to OrderStatus
OrderStatus _parseStatus(dynamic v) {
  if (v == null) return OrderStatus.belumBayar;
  final s = v.toString().toLowerCase().trim();

  if (s.contains('belum') || s.contains('pending') || s.contains('unpaid')) {
    return OrderStatus.belumBayar;
  }
  if (s.contains('proses') || s.contains('processing')) {
    return OrderStatus.diproses;
  }
  if (s.contains('kirim') || s.contains('shipped') || s.contains('dikirim')) {
    return OrderStatus.dikirim;
  }
  if (s.contains('terima') || s.contains('delivered')) {
    return OrderStatus.diterima;
  }
  if (s.contains('selesai') || s.contains('completed') || s.contains('complete')) {
    return OrderStatus.selesai;
  }
  // default fallback
  return OrderStatus.belumBayar;
}

/// Ringkasan order dari backend — model kecil, praktis, langsung dari API.
class BackendOrder {
  final String id;
  final String status; // raw status string
  final String productName;
  final String productImage;
  final int price;
  final int quantity;
  final DateTime createdAt;

  BackendOrder({
    required this.id,
    required this.status,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

    OrderStatus get parsedStatus => _parseStatus(status);

  factory BackendOrder.fromJson(Map<String, dynamic> json) {
    // beberapa backend bungkus data di field 'data' / 'order'
    final Map<String, dynamic> root = <String, dynamic>{}..addAll(json);
    // jika ada objek data yang berisi order, gunakan itu
    if ((json['data'] is Map) && (json['data'] as Map).containsKey('id')) {
      try {
        root.addAll(Map<String, dynamic>.from(json['data'] as Map));
      } catch (_) {}
    }

    String id = root['order_id'].toString();

    if (id.isEmpty) {
      // coba cari id di nested object
      final maybe = root['order'] ?? root['data'];
      if (maybe is Map && (maybe['id'] != null || maybe['order_id'] != null)) {
        id = (maybe['id'] ?? maybe['order_id']).toString();
      }
    }

    final status = (root['status'] ??
            root['order_status'] ??
            root['state'] ??
            '')
        .toString();

    final productName = (root['product_name'] ??
            root['name'] ??
            root['title'] ??
            root['product'] ??
            '')
        .toString();

    final productImage = (root['product_image'] ??
            root['image'] ??
            root['image_path'] ??
            root['thumbnail'] ??
            '')
        .toString(); 

final price = _parseInt(
  root['total_price'] ?? 0   // ← FIELD BACKEND ASLI
);

final quantity = 1; // backend tidak kirim detail item

final createdAt = _parseDate(
  root['order_date']        // ← FIELD BACKEND ASLI
);


    return BackendOrder(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      status: status,
      productName: productName,
      productImage: productImage,
      price: price,
      quantity: quantity,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'product_name': productName,
      'product_image': productImage,
      'price': price,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Bantu konversi ke AppOrder (butuh Product, kalau gak tersedia buat Product ringan)
AppOrder toAppOrder() {
  final item = OrderItem(
    product: Product(
      productId: null,
      storeId: null,
      name: productName,
      description: '',
      price: price,
      discount: null,
      imagePath: productImage,
      stock: 0,
      categoryId: null,
      storeName: null,
      sizes: null,
    ),
    quantity: quantity,
    unitPrice: price,
  );

  return AppOrder(
    id: id,
    items: [item],
    status: _parseStatus(status),
    createdAt: createdAt,
    paymentMethod: 'COD',
  );
}


/// Model aplikasi yang dipakai OrderProvider (AppOrder).
/// Struktur ini mengikuti yang sudah ada di OrderProvider contoh sebelumnya.
/*class AppOrder {
  final String id;
  final Product product;
  final OrderStatus status;
  final DateTime createdAt;

  AppOrder({
    required this.id,
    required this.product,
    required this.status,
    required this.createdAt,
  });

  AppOrder copyWith({
    String? id,
    Product? product,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return AppOrder(
      id: id ?? this.id,
      product: product ?? this.product,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppOrder.fromJson(Map<String, dynamic> json) {
    // support jika product dikirim sebagai Map atau hanya summary
    Product p;
    if (json['product'] is Map<String, dynamic>) {
      try {
        p = Product.fromJson(Map<String, dynamic>.from(json['product']));
      } catch (_) {
        p = Product(
          productId: json['product']?['productId'] ?? json['product']?['id'],
          storeId: null,
          name: json['product']?['name']?.toString() ?? '',
          description: '',
          price: _parseNum(json['product']?['price'] ?? 0),
          discount: null,
          imagePath: json['product']?['image']?.toString() ?? '',
          stock: _parseInt(json['product']?['stock'] ?? 0),
          categoryId: null,
          storeName: null,
          sizes: null,
        );
      }
    } else {
      // fallback: buat Product sederhana dari fields yang mungkin ada
      p = Product(
        productId: json['product_id'] ?? json['pid'],
        storeId: json['store_id'] ?? null,
        name: json['product_name']?.toString() ?? json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        price: _parseNum(json['price'] ?? json['product_price'] ?? 0),
        discount: null,
        imagePath: json['product_image']?.toString() ?? '',
        stock: _parseInt(json['stock'] ?? 0),
        categoryId: null,
        storeName: null,
        sizes: null,
      );
    }

    final status = _parseStatus(json['status'] ?? json['order_status'] ?? json['state']);
    final createdAt = _parseDate(json['createdAt'] ?? json['created_at'] ?? json['waktu']);

    return AppOrder(
      id: json['id']?.toString() ?? 'order-${DateTime.now().millisecondsSinceEpoch}',
      product: p,
      status: status,
      createdAt: createdAt,
    );
  }*/
}