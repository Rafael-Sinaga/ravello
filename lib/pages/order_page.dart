// lib/pages/order_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/app_order.dart'; // AppOrder
import '../models/order_item.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.orders; // List<AppOrder>

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          centerTitle: true,
          title: const Text(
            'Pesanan Saya',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(42),
            child: Container(
              color: Colors.white,
              child: const TabBar(
                isScrollable: true,
                labelColor: primaryColor,
                unselectedLabelColor: Color(0xFF6F7A74),
                indicatorColor: primaryColor,
                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(text: 'Belum Bayar'),
                  Tab(text: 'Dikirim'),
                  Tab(text: 'Diterima'),
                  Tab(text: 'Selesai'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            // Belum Bayar
            _buildUnpaidTab(orders),
            // Dikirim
            _buildEmptyState(
              message: 'Belum ada pesanan yang sedang dikirim',
            ),
            // Diterima
            _buildEmptyState(
              message: 'Belum ada pesanan yang diterima',
            ),
            // Selesai
            _buildOrderList(orders),
          ],
        ),
      ),
    );
  }

  Widget _buildUnpaidTab(List<AppOrder> orders) {
    final unpaid = orders
        .where((o) => o.status == OrderStatus.belumBayar)
        .toList();

    return Column(
      children: [
        // Alamat (UI)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
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
                    Icons.location_on_outlined,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alamat Pengiriman',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Rumah Utama • Jl. Contoh No. 123, Jakarta Selatan',
                        style: TextStyle(
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
        ),

        Expanded(
          child: unpaid.isEmpty
              ? _buildEmptyState(
                  message: 'Belum ada pesanan menunggu pembayaran',
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: unpaid.length,
                  itemBuilder: (context, index) {
                    final order = unpaid[index];
                    final items = order.items;
                    final firstImage = items.isNotEmpty ? items.first.product.imagePath : '';
                    final totalPrice = order.totalPrice;
                    final totalQty = order.totalQuantity;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.16)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // HEADER: status + tanggal
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.receipt_long,
                                        size: 18, color: primaryColor),
                                    SizedBox(width: 6),
                                    Text(
                                      'Menunggu pembayaran',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  'Bayar sebelum 12.00',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6F7A74),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // PRODUK RINGKASAN: thumbnail pertama + ringkasan jumlah
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // NAMA BARANG
                                      Text(
                                        items.first.product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      // NAMA TOKO
                                      Text(
                                        items.first.product.storeName ?? 'Toko',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6F7A74),
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      // QTY
                                      Text(
                                        'Qty: $totalQty',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6F7A74),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Pesanan akan diproses setelah pembayaran terkonfirmasi.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6F7A74),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Items: $totalQty • ${items.length} produk',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF6F7A74),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Metode: Transfer Bank',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6F7A74),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rp${totalPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),

        if (unpaid.isNotEmpty) _buildPaymentConfirmationBar(context),
      ],
    );
  }

  Widget _buildPaymentConfirmationBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konfirmasi Pembayaran',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Upload bukti transfer untuk melanjutkan proses pesanan.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                _showUploadProofBottomSheet(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Upload\nBukti',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadProofBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 18,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const Text(
                'Upload Bukti Pembayaran',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan foto bukti transfer jelas dan tidak blur.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.receipt_long_outlined,
                    size: 40,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.photo_outlined, size: 18),
                      label: const Text('Galeri', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.camera_alt_outlined, size: 18),
                      label: const Text('Kamera', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        side: const BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Bukti pembayaran berhasil dikirim.'),
                        backgroundColor: primaryColor,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Kirim Bukti',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderList(List<AppOrder> orders) {
    final done = orders
        .where((o) => o.status == OrderStatus.selesai)
        .toList();

    if (done.isEmpty) {
      return _buildEmptyState(
        message: 'Belum ada pesanan yang selesai',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: done.length,
      itemBuilder: (context, index) {
        final order = done[index];
        final items = order.items;
        final firstImage = items.isNotEmpty ? items.first.product.imagePath : '';
        final totalPrice = order.totalPrice;
        final totalQty = order.totalQuantity;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.storefront_rounded, size: 18, color: primaryColor),
                        SizedBox(width: 6),
                        Text(
                          'Toko Kamu',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2F4E8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                const Text(
                  'Pesanan telah tiba pada 5 Okt',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6F7A74)),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dikirim ke: Rumah Utama, Jakarta Selatan',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6F7A74)),
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE3ECF4)),
                const SizedBox(height: 10),

                // DETAIL PRODUK RINGKAS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: firstImage.isNotEmpty
                          ? Image.asset(
                              firstImage,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                            )
                          : Container(width: 64, height: 64, color: const Color(0xFFF3F4F6)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            items.length == 1 ? items.first.product.name : '${items.first.product.name} dan ${items.length - 1} item lain',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: $totalQty',
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
                      'Rp${totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE3ECF4)),
                const SizedBox(height: 8),

                // FOOTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pesanan selesai',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6F7A74)),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Detail pesanan belum diimplementasi.')),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Lihat Detail', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fitur beli lagi belum diimplementasi.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          child: const Text('Beli Lagi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({String message = 'Belum ada pesanan'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 3)),
              ],
            ),
            child: const Icon(Icons.insert_drive_file_outlined, size: 40, color: primaryColor),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6F7A74), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
