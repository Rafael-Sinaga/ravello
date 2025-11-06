// lib/pages/notification_page.dart
import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Data dummy untuk notifikasi pesanan selesai
  final List<Map<String, dynamic>> completedOrders = const [
    {
      'id': 'ORD001',
      'productName': 'Gelang Rajut',
      'productImage': 'assets/images/Gelang_rajut.png',
      'price': 240000,
      'status': 'selesai',
      'orderDate': '2024-01-15',
      'timeAgo': '1j',
    },
    {
      'id': 'ORD002',
      'productName': 'Jersey FC Barcelona',
      'productImage': 'assets/images/Jersey.png',
      'price': 120000,
      'status': 'selesai',
      'orderDate': '2024-01-14',
      'timeAgo': '2j',
    },
    {
      'id': 'ORD003',
      'productName': 'Rolex KW Super',
      'productImage': 'assets/images/Rolex_KW.png',
      'price': 300000,
      'status': 'selesai',
      'orderDate': '2024-01-13',
      'timeAgo': '5j',
    },
    {
      'id': 'ORD004', 
      'productName': 'Sepatu Sport',
      'productImage': 'assets/images/Sepatu.png',
      'price': 200000,
      'status': 'diproses',
      'orderDate': '2024-01-15',
      'timeAgo': '1h',
    },
    {
      'id': 'ORD005',
      'productName': 'Tas Kulit Lokal',
      'productImage': 'assets/images/Gelang_rajut.png', // placeholder
      'price': 185000,
      'status': 'dikirim',
      'orderDate': '2024-01-15',
      'timeAgo': '2h',
    },
  ];

  // Format currency
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // Get status text dan color
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'selesai':
        return {
          'text': 'Pesanan Selesai',
          'color': Colors.green,
          'description': 'Beri nilai untuk pesanan yang sudah selesai'
        };
      case 'diproses':
        return {
          'text': 'Pesanan Diproses',
          'color': Colors.orange,
          'description': 'Pesanan Anda sedang dalam proses pengiriman'
        };
      case 'dikirim':
        return {
          'text': 'Pesanan Dikirim',
          'color': Colors.blue,
          'description': 'Pesanan Anda telah dikirim oleh kurir'
        };
      default:
        return {
          'text': 'Pesanan',
          'color': Colors.grey,
          'description': 'Status pesanan'
        };
    }
  }

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
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: completedOrders.length,
              itemBuilder: (context, index) {
                final order = completedOrders[index];
                final statusInfo = _getStatusInfo(order['status']);

                return _buildNotificationItem(
                  order: order,
                  statusInfo: statusInfo,
                  onTap: () {
                    _showRatingDialog(context, order);
                  },
                );
              },
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
    required Map<String, dynamic> order,
    required Map<String, dynamic> statusInfo,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: order['status'] == 'selesai' ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar produk
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      order['productImage'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.shopping_bag, color: Colors.grey),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Info produk dan status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status dengan color coding
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusInfo['color'],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            statusInfo['text'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: statusInfo['color'],
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            order['timeAgo'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Nama produk
                      Text(
                        order['productName'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Harga
                      Text(
                        'Rp ${_formatPrice(order['price'])}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF124170),
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Deskripsi status
                      Text(
                        statusInfo['description'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6F7D8D),
                          height: 1.4,
                          fontFamily: 'Poppins',
                        ),
                      ),

                      // Tombol untuk pesanan selesai
                      if (order['status'] == 'selesai') ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: onTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF124170),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Beri Nilai',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context, Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Beri Nilai Produk',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order['productName'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Bagaimana kualitas produk?'),
            const SizedBox(height: 8),
            // Tambahkan rating stars di sini jika mau
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Terima kasih telah menilai ${order['productName']}'),
                  backgroundColor: const Color(0xFF124170),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF124170),
            ),
            child: const Text('Kirim Nilai'),
          ),
        ],
      ),
    );
  }
}