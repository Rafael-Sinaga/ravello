// lib/models/product_model.dart

class Product {
  final int? id;
  final String name;
  final double price;
  final String imagePath;       // dipakai untuk HomePage & DetailProduct
  final String description;
  final double? discount;
  final int? stock;
  final int? categoryId;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.discount,
    this.stock,
    this.categoryId,
  });

  /// Factory dari JSON API
  factory Product.fromJson(Map<String, dynamic> json) {
    // price bisa int / double / string
    final rawPrice = json['price'];
    double price;
    if (rawPrice is int) {
      price = rawPrice.toDouble();
    } else if (rawPrice is double) {
      price = rawPrice;
    } else {
      price = double.tryParse(rawPrice.toString()) ?? 0;
    }

    // discount optional
    final rawDiscount = json['discount'];
    double? discount;
    if (rawDiscount != null) {
      if (rawDiscount is int) {
        discount = rawDiscount.toDouble();
      } else if (rawDiscount is double) {
        discount = rawDiscount;
      } else {
        discount = double.tryParse(rawDiscount.toString());
      }
    }

    int? stock;
    final rawStock = json['stock'];
    if (rawStock is int) {
      stock = rawStock;
    } else if (rawStock != null) {
      stock = int.tryParse(rawStock.toString());
    }

    return Product(
      id: json['product_id'] as int? ?? json['id'] as int?,
      name: json['product_name'] ?? json['name'] ?? '',
      price: price,
      // sementara kalau backend belum kirim image_url,
      // pakai placeholder asset
      imagePath: json['image_url'] ?? 'assets/images/sepatu.png',
      description: json['description'] ?? '',
      discount: discount,
      stock: stock,
      categoryId: json['category_id'] as int?,
    );
  }
}

/// Dulu list dummy dipakai HomePage.
/// Sekarang HomePage pakai data dari backend, jadi ini boleh dikosongkan
/// (biarin aja tetap ada supaya file lain yang masih import nggak error).
final List<Product> products = [];
