import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/app_order.dart';

class OrderProvider with ChangeNotifier {
  final List<AppOrder> _orders = [];

  List<AppOrder> get orders => List.unmodifiable(_orders);

  // Dipanggil dari Checkout ketika user konfirmasi
  void addOrder(Product product) {
    final newOrder = AppOrder(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      status: OrderStatus.belumBayar,
      createdAt: DateTime.now(),
    );
    _orders.add(newOrder);
    notifyListeners();
  }

  // Helper kalau kamu mau update berdasarkan id dari backend nanti
  void updateStatusById(String id, OrderStatus newStatus) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: newStatus);
    notifyListeners();
  }

  // Versi simpel: update dengan objeknya langsung
  void updateStatus(AppOrder order, OrderStatus newStatus) {
    final idx = _orders.indexOf(order);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: newStatus);
    notifyListeners();
  }

  // Untuk filter di Tab/tab penjual
  List<AppOrder> byStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

  // --- kompatibilitas lama ke NotificationPage lama ---

  String statusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.belumBayar:
        return 'Belum Bayar';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.dikirim:
        return 'Dikirim';
      case OrderStatus.diterima:
        return 'Diterima';
      case OrderStatus.selesai:
        return 'Selesai';
    }
  }

  // kalau masih ada yang manggil getStatus(product)
  String getStatus(Product product) {
    final order =
        _orders.firstWhere((o) => o.product == product, orElse: () => 
          AppOrder(id: '', product: product, status: OrderStatus.belumBayar, createdAt: DateTime.now()),
        );
    return statusText(order.status);
  }
}
