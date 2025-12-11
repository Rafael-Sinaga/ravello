// lib/models/app_order.dart
import 'order_item.dart';

enum OrderStatus {
  belumBayar,
  diproses,
  dikirim,
  diterima,
  selesai,
}

class AppOrder {
  final String id;
  final List<OrderItem> items;
  final OrderStatus status;
  final DateTime createdAt;

  AppOrder({
    required this.id,
    required this.items,
    required this.status,
    required this.createdAt,
  });

  AppOrder copyWith({
    String? id,
    List<OrderItem>? items,
    OrderStatus? status,
    DateTime? createdAt,
  }) {
    return AppOrder(
      id: id ?? this.id,
      items: items ?? List<OrderItem>.from(this.items),
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get totalQuantity {
    if (items.isEmpty) return 0;
    return items.fold(0, (acc, it) => acc + it.quantity);
  }

  num get totalPrice {
    if (items.isEmpty) return 0;
    return items.fold<num>(0, (acc, it) => acc + it.totalPrice);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((i) => i.toJson()).toList(),
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppOrder.fromJson(Map<String, dynamic> json) {
    final List<OrderItem> items = (json['items'] as List<dynamic>? ?? [])
        .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final statusIndex = json['status'] is int ? json['status'] : int.tryParse(json['status'].toString()) ?? 0;

    return AppOrder(
      id: json['id']?.toString() ?? 'INV-0',
      items: items,
      status: OrderStatus.values[statusIndex.clamp(0, OrderStatus.values.length - 1)],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
