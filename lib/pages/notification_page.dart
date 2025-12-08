import 'package:flutter/material.dart';
import '../models/app_order.dart'; // <-- pakai AppOrder, bukan Product

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
                final product = order.product; // asumsi AppOrder punya field `product`
                final status = order.status;    // dan field `status`

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: _buildProductImage(product.imagePath),
                  title: Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  subtitle: Text(
                    'Status: $status',
                    style: TextStyle(
                      color: status == 'Selesai'
                          ? Colors.green
                          : const Color(0xFF124170),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                    ),
                  ),
                  trailing: Icon(
                    status == 'Selesai'
                        ? Icons.check_circle
                        : Icons.local_shipping,
                    color: status == 'Selesai'
                        ? Colors.green
                        : Colors.orangeAccent,
                  ),
                );
              },
            ),
    );
  }

  /// kecil: supaya URL/network & asset sama-sama aman
  Widget _buildProductImage(String path) {
    final isNetwork = path.startsWith('http');
    final image = isNetwork
        ? Image.network(
            path,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
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
  }
}
