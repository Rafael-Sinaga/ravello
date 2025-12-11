// lib/models/order_model.dart
// Model ringan khusus komunikasi dengan backend

class BackendOrder {
  final String id;
  final String status; // pending / diproses / dikirim / selesai
  final String productName;
  final String productImage;
  final int price;
  final int quantity;
  final DateTime createdAt;

  BackendOrder({
    required this.id,
    required this.status,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

  factory BackendOrder.fromJson(Map<String, dynamic> json) {
    return BackendOrder(
      id: json['id'].toString(),
      status: json['status'].toString(), 
      productName: json['product_name']?.toString() ?? '',
      productImage: json['product_image']?.toString() ?? '',
      price: int.tryParse(json['price'].toString()) ?? 0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
