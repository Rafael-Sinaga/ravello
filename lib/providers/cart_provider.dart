// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = <CartItem>[];

  /// Read-only view
  List<CartItem> get items => List.unmodifiable(_items);

  /// Tambah produk ke keranjang.
  /// Kalau produk punya varian ukuran, size wajib diisi.
  /// Mengembalikan true kalau sukses, false kalau gagal (size wajib).
  bool addToCart(Product product, {String? size}) {
    final bool hasSizes = product.sizes?.isNotEmpty ?? false;

    if (hasSizes && (size == null || size.isEmpty)) {
      if (kDebugMode) {
        debugPrint('CartProvider.addToCart: gagal - size belum dipilih');
      }
      return false;
    }

    final int index = _items.indexWhere((CartItem item) {
      final String aId = _safeIdToString(item.product.productId);
      final String bId = _safeIdToString(product.productId);
      final String aSize = item.size ?? '';
      final String bSize = size ?? '';
      return aId == bId && aSize == bSize;
    });

    if (index != -1) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(product: product, size: size, quantity: 1));
    }

    notifyListeners();
    return true;
  }

  static String _safeIdToString(dynamic id) {
    if (id == null) return '';
    return id.toString();
  }

  void removeItem(CartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void increaseQuantity(CartItem item) {
    final int i = _items.indexOf(item);
    if (i != -1) {
      _items[i].quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(CartItem item) {
    final int i = _items.indexOf(item);
    if (i != -1) {
      if (_items[i].quantity > 1) {
        _items[i].quantity -= 1;
      } else {
        _items.removeAt(i);
      }
      notifyListeners();
    }
  }

  double get totalPrice {
    double total = 0.0;
    for (final CartItem item in _items) {
      total += item.product.price.toDouble() * item.quantity;
    }
    return total;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
