// lib/models/cart_model.dart
import 'product_model.dart';

class CartItem {
  /// Produk yang dibeli
  final Product product;

  /// Ukuran yang dipilih (boleh null untuk flow lama yang belum pakai ukuran)
  String? size;

  /// Jumlah barang
  int quantity;

  CartItem({
    required this.product,
    this.size,
    this.quantity = 1,
  });
}
