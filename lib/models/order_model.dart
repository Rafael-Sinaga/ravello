// lib/models/order_model.dart - BUAT FILE INI JIKA BELUM ADA
class Order {
  final String id;
  final String productName;
  final String productImage;
  final int price;
  final int quantity;
  final String status; // 'diproses', 'dikirim', 'selesai'
  final DateTime orderDate;

  Order({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.status,
    required this.orderDate,
  });

  Order copyWith({String? status}) {
    return Order(
      id: id,
      productName: productName,
      productImage: productImage,
      price: price,
      quantity: quantity,
      status: status ?? this.status,
      orderDate: orderDate,
    );
  }
}