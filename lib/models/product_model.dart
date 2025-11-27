// lib/models/product_model.dart

class Product {
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final double? discount;
  final int stock; // stok produk

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.discount,
    this.stock = 0, // default supaya aman kalau nggak diisi
  });
}

// Untuk sekarang: TIDAK ADA DUMMY DATA.
// List ini akan diisi dari:
// - Kelola Produk (ManageProductsPage) di frontend
// - Nanti: data dari backend API
final List<Product> products = [];
