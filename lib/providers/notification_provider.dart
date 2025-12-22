import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<AppNotification> _notifications = [];

  /// =========================
  /// GETTERS
  /// =========================

  List<AppNotification> get allNotifications => List.unmodifiable(_notifications);

  List<AppNotification> get buyerNotifications =>
      _notifications.where((n) => n.role == 'buyer').toList();

  List<AppNotification> get sellerNotifications =>
      _notifications.where((n) => n.role == 'seller').toList();

  int get unreadBuyerCount =>
      buyerNotifications.where((n) => !n.isRead).length;

  int get unreadSellerCount =>
      sellerNotifications.where((n) => !n.isRead).length;

  /// =========================
  /// ACTIONS
  /// =========================

  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead({required String role}) {
    for (final n in _notifications) {
      if (n.role == role) {
        n.isRead = true;
      }
    }
    notifyListeners();
  }

  void removeNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearByRole(String role) {
    _notifications.removeWhere((n) => n.role == role);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// =========================
  /// HELPER (BIAR RAPI)
  /// =========================

  AppNotification buildSellerOrderNotification({
    required String orderId,
    required String buyerName,
    required int totalItem,
    Map<String, dynamic>? extraData,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'seller',
      title: 'Order Baru Masuk',
      message: 'Pesanan dari $buyerName • $totalItem item',
      createdAt: DateTime.now(),
      data: {
        'orderId': orderId,
        ...?extraData,
      },
    );
  }

  AppNotification buildBuyerStatusNotification({
    required String orderId,
    required String status,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: 'buyer',
      title: 'Update Pesanan',
      message: 'Pesanan kamu $status',
      createdAt: DateTime.now(),
      data: {
        'orderId': orderId,
        'status': status,
      },
    );
  }
}
