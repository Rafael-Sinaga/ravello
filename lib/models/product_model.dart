// lib/models/product_model.dart
class Product {
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final double? discount; // Tambahkan atribut diskon opsional

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.discount,
  });
}

// Contoh data produk
final List<Product> products = [
  Product(
    name: 'Kemeja Batik Premium',
    price: 250000,
    imagePath: 'assets/images/batik.jpg',
    description:
        'Kemeja batik dengan bahan katun premium, nyaman dipakai dan cocok untuk acara formal maupun santai.',
    discount: 20, // Diskon 20%
  ),
  Product(
    name: 'Tas Kulit Handmade',
    price: 350000,
    imagePath: 'assets/images/tas_kulit.jpg',
    description:
        'Tas kulit asli buatan tangan dengan jahitan rapi dan desain elegan. Cocok untuk pria maupun wanita.',
    discount: 10,
  ),
  Product(
    name: 'Gelang Manik Eksklusif',
    price: 120000,
    imagePath: 'assets/images/gelang.jpg',
    description:
        'Gelang manik buatan pengrajin lokal dengan desain etnik yang menawan. Tersedia dalam berbagai warna.',
  ),
];
