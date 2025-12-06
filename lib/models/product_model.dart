// lib/models/product_model.dart

/// Model produk yang kompatibel dengan:
/// - kode UI lama (name, price, imagePath, discount)
/// - data dari backend (product_id, product_name, image_url, dll)
class Product {
  /// ID produk dari backend (bisa null kalau produk lokal/dummy)
  final int? productId;

  /// Nama produk — dipakai di semua UI
  final String name;

  /// Deskripsi produk (opsional)
  final String description;

  /// Harga produk
  final num price;

  /// Stok produk (default 0 kalau nggak diisi)
  final int stock;

  /// Persentase diskon (0–100), nullable
  final double? discount;

  /// ID kategori dari backend (opsional)
  final int? categoryId;

  /// Path gambar yang dipakai UI:
  /// - bisa path asset lokal: 'assets/images/sepatu.png'
  /// - bisa URL penuh dari backend: 'http://.../uploads/xxx.png'
  final String imagePath;

  /// Nama toko (kalau datang dari backend)
  final String? storeName;

  /// ID toko (kalau datang dari backend)
  final int? storeId;

  /// Status produk di-boost atau tidak (lokal/backend)
  final bool isBoosted;

  /// Convenience getter, kalau lu mau nama yang lebih “web-ish”
  String get imageUrl => imagePath;

  Product({
    this.productId,
    required this.name,
    this.description = '',
    required this.price,
    this.stock = 0,
    this.discount,
    this.categoryId,
    required this.imagePath,
    this.storeName,
    this.storeId,
    this.isBoosted = false,
  });

  /// Factory untuk parse dari JSON backend
  ///
  /// Backend kirim field:
  /// - product_id
  /// - product_name
  /// - description
  /// - price
  /// - stock
  /// - discount (opsional)
  /// - category_id
  /// - image_url  (URL penuh atau path relatif)
  /// - store_name
  /// - store_id
  /// - is_boosted / boosted / isBoosted (opsional)
  /// atau kadang:
  /// - store: { id / store_id, name / store_name }
  factory Product.fromJson(Map<String, dynamic> json) {
    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? _asDouble(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    bool _asBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = v.toString().toLowerCase().trim();
      return s == 'true' || s == '1' || s == 'yes';
    }

    final rawImage =
        (json['image_url'] ?? json['imagePath'] ?? json['image'] ?? '').toString();

    // kalau backend nggak kirim gambar, pakai placeholder biar nggak error asset
    final resolvedImage = rawImage.isEmpty
        ? 'https://via.placeholder.com/300x300?text=No+Image'
        : rawImage;

    // --- dukung format nested: { store: { id / store_id, name / store_name } } ---
    String? nestedStoreName;
    int? nestedStoreId;
    final storeJson = json['store'];
    if (storeJson is Map<String, dynamic>) {
      final sName = storeJson['store_name'] ?? storeJson['name'];
      nestedStoreName = sName?.toString();
      nestedStoreId = _asInt(storeJson['store_id'] ?? storeJson['id']);
    }

    final bool boostedFlag = _asBool(
      json['is_boosted'] ?? json['boosted'] ?? json['isBoosted'],
    );

    return Product(
      productId: _asInt(json['product_id']),
      name: (json['product_name'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      // price dikonversi pakai helper, aman kalau "90000" (String)
      price: _asDouble(json['price']) ?? 0,
      stock: _asInt(json['stock']) ?? 0,
      discount: _asDouble(json['discount']),
      categoryId: _asInt(json['category_id']),
      imagePath: resolvedImage,
      storeName: nestedStoreName ?? json['store_name']?.toString(),
      storeId: nestedStoreId ?? _asInt(json['store_id']),
      isBoosted: boostedFlag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'discount': discount,
      'category_id': categoryId,
      'image_url': imagePath,
      'store_name': storeName,
      'store_id': storeId,
      'is_boosted': isBoosted,
    };
  }
}
