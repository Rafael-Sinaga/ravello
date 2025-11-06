// lib/pages/notification_page.dart
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF124170), size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Notifikasi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF124170),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
      body: Column(
        children: [
          // Header Status Pesanan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: const Color(0xFFF8FBFD),
            child: const Text(
              'Status Pesanan',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF124170),
              ),
            ),
          ),

          // List Notifikasi
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                _buildNotificationItem(
                  title: 'Pesanan Selesai',
                  description: 'Beri nilai untuk pesanan yang sudah selesai',
                  time: '1j',
                ),
                _buildNotificationItem(
                  title: 'Pesanan Selesai',
                  description: 'Beri nilai untuk pesanan yang sudah selesai',
                  time: '2j',
                ),
                _buildNotificationItem(
                  title: 'Pesanan Selesai',
                  description: 'Beri nilai untuk pesanan yang sudah selesai',
                  time: '5j',
                ),
                _buildNotificationItem(
                  title: 'Pesanan Diproses',
                  description: 'Pesanan Anda sedang dalam proses pengiriman',
                  time: '1h',
                ),
                _buildNotificationItem(
                  title: 'Pesanan Dikirim',
                  description: 'Pesanan Anda telah dikirim oleh kurir',
                  time: '2h',
                ),
              ],
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              'Sudah menampilkan semua notifikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String description,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon notifikasi
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF124170).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Color(0xFF124170),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Konten notifikasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6F7D8D),
                    height: 1.4,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          
          // Waktu
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}