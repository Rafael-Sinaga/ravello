// lib/pages/notification_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/app_order.dart';
import '../models/order_item.dart'; // pastikan ada
import '../models/product_model.dart';

class NotificationPage extends StatelessWidget {
  final List<AppOrder> orders;

  const NotificationPage({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pesanan',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                // ambil first item sebagai representasi (fallback aman)
                final List<OrderItem> items = order.items;
                final OrderItem? firstItem = items.isNotEmpty ? items.first : null;
                final Product? product = firstItem?.product;

                final String titleText = product != null
                    ? (items.length == 1
                        ? product.name
                        : '${product.name} dan ${order.totalQuantity - firstItem!.quantity} item lain')
                    : 'Pesanan #${order.id}';

                final String statusText = _statusToLabel(order.status);
                final bool isDone = order.status == OrderStatus.selesai;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildProductImage(product?.imagePath ?? ''),
                  title: Text(
                    titleText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    'Status: $statusText',
                    style: TextStyle(
                      color: isDone ? Colors.green : const Color(0xFF124170),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    isDone ? Icons.check_circle : Icons.local_shipping,
                    color: isDone ? Colors.green : Colors.orangeAccent,
                  ),
                  onTap: () {
                    // TODO: navigasi ke detail order jika ada
                  },
                );
              },
            ),
    );
  }

  String _statusToLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.belumBayar:
        return 'Menunggu Pembayaran';
      case OrderStatus.diproses:
        return 'Diproses';
      case OrderStatus.dikirim:
        return 'Dikirim';
      case OrderStatus.diterima:
        return 'Diterima';
      case OrderStatus.selesai:
        return 'Selesai';
      default:
        return status.toString();
    }
  }

  Widget _buildProductImage(String path) {
    if (path.isEmpty) {
      return _placeholderImage();
    }

    final bool isNetwork = path.startsWith('http') || path.startsWith('https');
    try {
      final image = isNetwork
          ? Image.network(
              path,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderImage(),
            )
          : Image.asset(
              path,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            );

      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: image,
      );
    } catch (_) {
      return _placeholderImage();
    }
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.image_not_supported,
        color: Color(0xFF9AA7AB),
      ),
    );
  }
}
