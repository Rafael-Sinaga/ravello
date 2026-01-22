// lib/providers/order_sync_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../models/app_order.dart';   // AppOrder YANG BENAR


/// Provider ini hanya menyimpan list BackendOrder dari server dan polling.
/// Ia juga menyediakan event callback supaya UI / OrderProvider lama bisa sinkron.
class OrderSyncProvider with ChangeNotifier {
  final void Function(List<AppOrder>)? onSyncToApp;

  OrderSyncProvider({this.onSyncToApp});

  List<BackendOrder> _orders = [];
  Timer? _pollTimer;
  bool _loading = false;

  List<BackendOrder> get orders => List.unmodifiable(_orders);
  bool get isLoading => _loading;

  /// Mulai polling; interval default 10 detik
  /// role: 'seller' atau 'buyer'
  void startPolling({
    required String role,
    int? userId,
    Duration interval = const Duration(seconds: 10),
  }) {
    _pollTimer?.cancel();
    // langsung refresh dulu supaya UI cepet punya data
    refresh(role: role, userId: userId);
    _pollTimer = Timer.periodic(interval, (_) => refresh(role: role, userId: userId));
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refresh({required String role, int? userId}) async {
    _loading = true;
    notifyListeners();
    try {
      final fetched = await OrderService.fetchOrders(role: role, userId: userId);
      final changed = _hasChanges(_orders, fetched);
      _orders = fetched;
      // 🔥 PUSH KE ORDERPROVIDER
      if (onSyncToApp != null) {
        final appOrders = fetched.map((e) => e.toAppOrder()).toList();

        onSyncToApp!(appOrders);
      }

    } catch (e) {
      // optionally log error
      debugPrint('OrderSyncProvider.refresh error: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool _hasChanges(List<BackendOrder> oldList, List<BackendOrder> newList) {
    if (oldList.length != newList.length) return true;
    final oldMap = {for (var o in oldList) o.id: o};
    for (var n in newList) {
      final o = oldMap[n.id];
      if (o == null) return true;
      if (o.status != n.status) return true;
    }
    return false;
  }

  BackendOrder? getById(String id) {
    for (final o in _orders) {
      if (o.id == id) return o;
    }
    return null;
  }
}
