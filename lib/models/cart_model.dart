// lib/models/cart_model.dart
import 'product_model.dart';

class CartItem {

  /// ID cart (nullable untuk local)
  final int? cartId;

  /// Produk
  final Product product;

  String? size;
  int quantity;

  /// Constructor LOCAL (untuk UI lama)
  CartItem({
    this.cartId,
    required this.product,
    this.size,
    this.quantity = 1,
  });

  /// Constructor dari API
  factory CartItem.fromApi(Map<String, dynamic> json) {
    return CartItem(
      cartId: json['cart_id'],
      product: Product(
        productId: json['product_id'],
        name: json['product_name'],
        description: '', // karena backend belum kirim
        price: double.parse(json['price'].toString()),
        imagePath: '', // nanti bisa diperbaiki
      ),
      quantity: json['quantity'],
    );
  }
}
