import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/order_provider.dart';

class NotificationPage extends StatelessWidget {
  final List<Product> orders;

  const NotificationPage({
    super.key,
    required this.orders,
  });

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

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
                final product = orders[index];
                final status = orderProvider.getStatus(product);

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Image.asset(
                    product.imagePath,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
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
                    color:
                        status == 'Selesai' ? Colors.green : Colors.orangeAccent,
                  ),
                );
              },
            ),
    );
  }
}
