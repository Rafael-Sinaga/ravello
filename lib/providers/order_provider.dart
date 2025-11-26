// lib/providers/order_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<_OrderStatus> _orders = [];

  /// List produk saja (dipakai di UI seperti OrderPage)
  List<Product> get orders => _orders.map((o) => o.product).toList();

  /// Ambil status untuk 1 produk
  String getStatus(Product product) {
    final order = _orders.firstWhere(
      (o) => o.product == product,
      orElse: () => _OrderStatus(product, 'Diproses'),
    );
    return order.status;
  }

  /// ✅ Tambah satu order saja (dipanggil dari CheckoutPage)
  void addOrder(Product product) {
    final existing = _orders.any((o) => o.product == product);
    if (!existing) {
      final orderStatus = _OrderStatus(product, 'Diproses');
      _orders.add(orderStatus);
      _startStatusTimer(orderStatus);
      notifyListeners();
    }
  }

  /// Tambah banyak product sekaligus (kalau mau dipakai di masa depan)
  void addOrders(List<Product> products) {
    for (var product in products) {
      final existing = _orders.any((o) => o.product == product);
      if (!existing) {
        final orderStatus = _OrderStatus(product, 'Diproses');
        _orders.add(orderStatus);
        _startStatusTimer(orderStatus);
      }
    }
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }

  void _startStatusTimer(_OrderStatus order) {
    // Timer simulasi perubahan status otomatis
    Timer(const Duration(seconds: 5), () {
      order.status = 'Sedang dikirim';
      notifyListeners();

      Timer(const Duration(seconds: 5), () {
        order.status = 'Selesai';
        notifyListeners();
      });
    });
  }
}

class _OrderStatus {
  final Product product;
  String status;

  _OrderStatus(this.product, this.status);
}
