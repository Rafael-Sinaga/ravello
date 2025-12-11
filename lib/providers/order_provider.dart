// lib/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import '../models/order_item.dart';
import '../models/app_order.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class OrderProvider with ChangeNotifier {
  final List<AppOrder> _orders = [];

  List<AppOrder> get orders => List.unmodifiable(_orders);

  /// Add single-product legacy (keep for compatibility)
  void addOrder(Product product, {int quantity = 1}) {
    final items = <OrderItem>[
      OrderItem(product: product, quantity: quantity, unitPrice: product.price),
    ];

    final newOrder = AppOrder(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      status: OrderStatus.belumBayar,
      createdAt: DateTime.now(),
    );

    _orders.add(newOrder);
    notifyListeners();
  }

  /// NEW: create one order from a list of CartItem (checkout)
  void addOrderFromCartItems(List<CartItem> cartItems) {
    final items = cartItems.map((c) {
      return OrderItem(
        product: c.product,
        quantity: c.quantity,
        unitPrice: c.product.price,
      );
    }).toList();

    if (items.isEmpty) return;

    final newOrder = AppOrder(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      items: items,
      status: OrderStatus.belumBayar,
      createdAt: DateTime.now(),
    );

    _orders.add(newOrder);
    notifyListeners();
  }

  // update status by id
  void updateStatusById(String id, OrderStatus newStatus) {
    final idx = _orders.indexWhere((o) => o.id == id);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: newStatus);
    notifyListeners();
  }

  void updateStatus(AppOrder order, OrderStatus newStatus) {
    final idx = _orders.indexOf(order);
    if (idx == -1) return;
    _orders[idx] = _orders[idx].copyWith(status: newStatus);
    notifyListeners();
  }

  List<AppOrder> byStatus(OrderStatus status) {
    return _orders.where((o) => o.status == status).toList();
  }

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

  // Return order that contains given product (fallback create temp order)
  AppOrder? orderContainingProduct(Product product) {
    try {
      return _orders.firstWhere((o) => o.items.any((it) => it.product.productId == product.productId));
    } catch (_) {
      return null;
    }
  }
}
