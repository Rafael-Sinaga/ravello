// lib/models/product_model.dart
class Product {
  final String name;
  final double price;
  final String imagePath;
  final String description;
  final double? discount;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.discount,
  });
}

// === Data produk utama (berasal dari HomePage kamu) ===
final List<Product> products = [
  Product(
    name: 'Gelang Rajut',
    price: 300000,
    imagePath: 'assets/images/Gelang_rajut.png',
    description: 'Gelang rajut warna-warni handmade cocok untuk segala usia.',
    discount: 30,
  ),
  Product(
    name: 'Jersey',
    price: 120000,
    imagePath: 'assets/images/Jersey.png',
    description: 'Jersey premium bahan halus dengan desain sporty elegan.',
  ),
  Product(
    name: 'Sepatu Abibas',
    price: 20000,
    imagePath: 'assets/images/Sepatu.png',
    description: 'Sepatu lokal gaya kasual dengan harga super terjangkau.',
    discount: 50,
  ),
  Product(
    name: 'Rolex KW',
    price: 300000,
    imagePath: 'assets/images/Rolex_KW.png',
    description: 'Jam tangan elegan, kualitas tinggi dengan harga ramah.',
    discount: 10,
  ),
  Product(
    name: 'Sepatu Kulit Lokal',
    price: 185000,
    imagePath: 'assets/images/sepatu.png',
    description: 'Sepatu kulit asli buatan pengrajin lokal berkualitas tinggi.',
  ),
];
