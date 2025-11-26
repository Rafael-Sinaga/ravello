// lib/pages/order_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/product_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  double _paymentProgress = 0; // untuk slider konfirmasi pembayaran
  bool _paymentJustConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderProvider>(context).orders;

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
            // Selesai -> semua order yang ada sekarang
            _buildOrderList(orders),
          ],
        ),
      ),
    );
  }

  // ================== TAB "BELUM BAYAR" ==================

  Widget _buildUnpaidTab(List<Product> orders) {
    return Column(
      children: [
        // KARTU ALAMAT PENGIRIMAN (UI saja, logika tidak diubah)
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
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
                TextButton(
                  onPressed: () {
                    // UI saja: bisa ditambahkan logika edit alamat nanti
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur ubah alamat belum diimplementasi.'),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Text(
                    'Ubah',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: orders.isEmpty
              ? _buildEmptyState(
                  message: 'Belum ada pesanan menunggu pembayaran',
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];

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

                            // PRODUK
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset(
                                    order.imagePath,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: const [
                                      SizedBox(height: 2),
                                      Text(
                                        'Pesanan akan diproses setelah pembayaran terkonfirmasi.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF6F7A74),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
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
                                  'Rp${order.price.toStringAsFixed(0)}',
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

        // SLIDER KONFIRMASI PEMBAYARAN
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: _buildPaymentSlider(),
        ),
      ],
    );
  }

  Widget _buildPaymentSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.25)),
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
            children: const [
              Icon(Icons.lock_open_rounded,
                  size: 18, color: primaryColor),
              SizedBox(width: 6),
              Text(
                'Konfirmasi Pembayaran',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Track "halus" dengan gradient tipis
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.06),
                  primaryColor.withOpacity(0.02),
                ],
              ),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 8,
                activeTrackColor: primaryColor,
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 22),
                overlayColor: primaryColor.withOpacity(0.15),
              ),
              child: Slider(
                value: _paymentProgress,
                min: 0,
                max: 100,
                onChanged: (value) {
                  setState(() {
                    _paymentProgress = value;
                  });

                  if (value >= 100 && !_paymentJustConfirmed) {
                    _paymentJustConfirmed = true;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Pembayaran berhasil dikonfirmasi.'),
                      ),
                    );

                    // reset slider dengan animasi kecil
                    Future.delayed(const Duration(milliseconds: 700), () {
                      if (!mounted) return;
                      setState(() {
                        _paymentProgress = 0;
                        _paymentJustConfirmed = false;
                      });
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _paymentProgress < 100
                ? 'Geser penuh ke kanan untuk mengkonfirmasi pembayaran.'
                : 'Melepas untuk menyelesaikan konfirmasi...',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6F7A74),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ================== LIST PESANAN (TAB "SELESAI") ==================

  Widget _buildOrderList(List<Product> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState(
        message: 'Belum ada pesanan yang selesai',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

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
                // HEADER: status + tanggal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.storefront_rounded,
                            size: 18, color: primaryColor),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6F7A74),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Dikirim ke: Rumah Utama, Jakarta Selatan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6F7A74),
                  ),
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFE3ECF4)),
                const SizedBox(height: 10),

                // DETAIL PRODUK
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        order.imagePath,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(height: 2),
                          Text(
                            'Jersey Home 23/24 • Size M',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Qty: 1',
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
                      'Rp${order.price.toStringAsFixed(0)}',
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

                // FOOTER: info + tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pesanan selesai',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6F7A74),
                      ),
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Detail pesanan belum diimplementasi.'),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: primaryColor),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Fitur beli lagi belum diimplementasi.'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Beli Lagi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
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

  // ================== EMPTY STATE (TAB KOSONG) ==================

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
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.insert_drive_file_outlined,
              size: 40,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6F7A74),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
