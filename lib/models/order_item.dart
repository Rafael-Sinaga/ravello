// lib/models/order_item.dart
import 'product_model.dart';

class OrderItem {
  final Product product;
  final int quantity;
  final num unitPrice;

  OrderItem({
    required this.product,
    this.quantity = 1,
    required this.unitPrice,
  });

  num get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      product: Product.fromJson(Map<String, dynamic>.from(json['product'] ?? {})),
      quantity: (json['quantity'] is int) ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 1,
      unitPrice: (json['unitPrice'] is num) ? json['unitPrice'] : num.tryParse(json['unitPrice'].toString()) ?? 0,
    );
  }
}
