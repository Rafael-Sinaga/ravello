// lib/models/app_order.dart
import 'product_model.dart';

enum OrderStatus {
  belumBayar,
  diproses,
  dikirim,
  diterima,
  selesai,
}

class AppOrder {
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
}
