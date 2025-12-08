// lib/pages/seller_order_page_detail.dart
import 'package:flutter/material.dart';

class SellerOrder {
  final String id;
  final String buyerName;
  final String address;
  final String status; // 'Baru', 'Diproses', 'Dikirim', 'Selesai'
  final DateTime createdAt;
  final int total;
  final String paymentMethod;
  final List<SellerOrderItem> items;
  final String note;

  SellerOrder({
    required this.id,
    required this.buyerName,
    required this.address,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.paymentMethod,
    required this.items,
    this.note = '',
  });
}

class SellerOrderItem {
  final String name;
  final String variant;
  final int qty;
  final int price; // per item

  SellerOrderItem({
    required this.name,
    required this.variant,
    required this.qty,
    required this.price,
  });
}

class SellerOrderPageDetail extends StatelessWidget {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  final SellerOrder order;

  /// NEW: callback ke parent untuk update status
  /// misal: onUpdateStatus('Dikirim');
  final ValueChanged<String>? onUpdateStatus;

  const SellerOrderPageDetail({
    super.key,
    required this.order,
    this.onUpdateStatus,
  });

  String _formatDate(DateTime dt) {
    // format simpel: 12 Okt 2025, 14:32
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final d = dt.day.toString().padLeft(2, '0');
    final m = months[dt.month - 1];
    final y = dt.year;
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$d $m $y, $hh:$mm';
  }

  String _formatPrice(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFF2563EB);
      case 'Diproses':
        return const Color(0xFFF59E0B);
      case 'Dikirim':
        return const Color(0xFF0EA5E9);
      case 'Selesai':
        return const Color(0xFF16A34A);
      default:
        return primaryColor;
    }
  }

  /// NEW: status berikutnya berdasarkan status sekarang
  String? _nextStatus(String status) {
    switch (status) {
      case 'Baru':
        return 'Diproses';
      case 'Diproses':
        return 'Dikirim';
      case 'Dikirim':
        return 'Selesai';
      default:
        // 'Selesai' atau status lain -> tidak ada lanjutan
        return null;
    }
  }

  /// NEW: label tombol berdasarkan status sekarang
  String _actionLabel(String status) {
    switch (status) {
      case 'Baru':
        return 'Terima & Proses';
      case 'Diproses':
        return 'Tandai Dikirim';
      case 'Dikirim':
        return 'Tandai Selesai';
      case 'Selesai':
        return 'Pesanan Selesai';
      default:
        return 'Proses Pesanan';
    }
  }

  /// NEW: deskripsi singkat yang ditampilkan di dialog konfirmasi
  String _actionDescription(String currentStatus, String? nextStatus) {
    if (nextStatus == null) {
      return 'Pesanan sudah berada pada status akhir.';
    }
    return 'Ubah status pesanan dari "$currentStatus" menjadi "$nextStatus"?';
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = order.items.fold<int>(
      0,
      (sum, item) => sum + item.price * item.qty,
    );
    const int serviceFee = 2000;
    final int total = subtotal + serviceFee;

    // NEW: hitung status berikut & label tombol sekali di sini
    final String? nextStatus = _nextStatus(order.status);
    final String actionLabel = _actionLabel(order.status);

    final bool isActionEnabled =
        nextStatus != null && onUpdateStatus != null && order.status != 'Selesai';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Rincian Pesanan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS & INFO ORDER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(order.status).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: _statusColor(order.status),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              order.status,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(order.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(order.createdAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6F7A74),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'ID Pesanan: ${order.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Metode Pembayaran: ${order.paymentMethod}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6F7A74),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // INFO PEMBELI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Info Pembeli',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.buyerName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6F7A74),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // PRODUK DIPESAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produk Dipesan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...order.items.map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5ECF4),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.variant,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6F7A74),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Qty: ${item.qty}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6F7A74),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Rp ${_formatPrice(item.price * item.qty)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // RINCIAN PEMBAYARAN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rincian Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPriceRow('Subtotal', subtotal),
                  const SizedBox(height: 4),
                  _buildPriceRow('Biaya Layanan', serviceFee),
                  const Divider(
                    height: 18,
                    color: Color(0xFFE5E7EB),
                  ),
                  _buildPriceRow('Total', total, isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (order.note.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catatan Pembeli',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      order.note,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4B5563),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // AKSI
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: hubungi pembeli (chat / whatsapp)
                    },
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text(
                      'Hubungi Pembeli',
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: !isActionEnabled
                        ? null
                        : () async {
                            // NEW: dialog konfirmasi sebelum update status
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Ubah Status Pesanan'),
                                content: Text(
                                  _actionDescription(order.status, nextStatus),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Ya, Lanjutkan'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true &&
                                nextStatus != null &&
                                onUpdateStatus != null) {
                              onUpdateStatus!(nextStatus);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Status pesanan diubah menjadi "$nextStatus".',
                                  ),
                                  backgroundColor: primaryColor,
                                ),
                              );

                              // Opsional: kembali ke halaman sebelumnya
                              Navigator.pop(context);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor:
                          primaryColor.withOpacity(0.35),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      actionLabel,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, int value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF6F7A74),
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        Text(
          'Rp ${_formatPrice(value)}',
          style: TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? primaryColor : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}
