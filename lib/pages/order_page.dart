// lib/pages/order_page.dart
import 'package:flutter/material.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Data dummy sementara
    final List<Map<String, dynamic>> orders = [
      {
        'image': 'assets/images/product1.png',
        'title': 'Kemeja Batik Elegan',
        'status': 'Sedang dikirim',
        'date': '2 November 2025',
        'price': 175000,
      },
      {
        'image': 'assets/images/product2.png',
        'title': 'Gelang Anyaman Rotan',
        'status': 'Selesai',
        'date': '28 Oktober 2025',
        'price': 85000,
      },
      {
        'image': 'assets/images/product3.png',
        'title': 'Totebag Tenun Etnik',
        'status': 'Dibatalkan',
        'date': '22 Oktober 2025',
        'price': 95000,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF124170),
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF124170)),
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF8FBFD),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  order['image'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                order['title'],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF124170),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    order['status'],
                    style: TextStyle(
                      color: order['status'] == 'Selesai'
                          ? Colors.green
                          : order['status'] == 'Dibatalkan'
                              ? Colors.red
                              : Colors.orange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order['date'],
                    style: const TextStyle(
                      color: Color(0xFF6F7D8D),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              trailing: Text(
                'Rp${order['price']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF124170),
                ),
              ),
              onTap: () {
                // nanti bisa diarahkan ke detail pesanan
              },
            ),
          );
        },
      ),
    );
  }
}
