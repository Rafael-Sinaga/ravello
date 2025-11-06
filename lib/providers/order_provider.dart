// lib/providers/order_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class OrderProvider extends ChangeNotifier {
  final List<Product> _orders = [];

  List<Product> get orders => _orders;

  void addOrders(List<Product> products) {
    _orders.addAll(products);
    notifyListeners();
  }

  void clearOrders() {
    _orders.clear();
    notifyListeners();
  }
}
