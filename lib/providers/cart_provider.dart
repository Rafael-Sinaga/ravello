import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  void addToCart(Product product) {
    if (!_items.contains(product)) {
      _items.add(product);
      notifyListeners();
    }
  }

  void removeItem(Product product) {
    _items.remove(product);
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0, (total, item) => total + item.price);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
