// lib/models/product_model.dart

/// Helper kecil untuk parse integer yang bisa datang sebagai int / double / String
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

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
      // ✅ pakai _parseInt supaya aman kalau backend ngirim "10" (String)
      id: _parseInt(json['product_id'] ?? json['id']),
      name: json['product_name'] ?? json['name'] ?? '',
      price: price,
      // sementara kalau backend belum kirim image_url,
      // pakai placeholder asset
      imagePath: json['image_url'] ?? 'assets/images/sepatu.png',
      description: json['description'] ?? '',
      discount: discount,
      stock: stock,
      categoryId: _parseInt(json['category_id']),
    );
  }
}

/// Dulu list dummy dipakai HomePage.
/// Sekarang HomePage pakai data dari backend, jadi ini boleh dikosongkan
/// (biarin aja tetap ada supaya file lain yang masih import nggak error).
final List<Product> products = [];
