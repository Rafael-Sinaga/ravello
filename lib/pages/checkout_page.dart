// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../models/product_model.dart';
import 'order_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  int _selectedShipping = 0;
  int _selectedPayment = 0;

  double _sliderValue = 0.0;
  bool _isSliding = false;

  // ==================== LOGIKA KONFIRMASI ====================
  void _handleConfirmPayment() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk di keranjang untuk di-checkout.'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    // Ambil produk pertama dari keranjang
    final Product product = cart.items.first;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.addOrder(product);

    // Opsional: hapus produk dari keranjang
    cart.removeItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan dikonfirmasi!'),
        backgroundColor: primaryColor,
      ),
    );

    // Arahkan ke halaman "Pesanan Saya"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrderPage()),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final Product? product =
        cart.items.isNotEmpty ? cart.items.first : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // kalau mau pakai bantuan / CS di checkout, taruh logic di sini
            },
            icon: const Icon(
              Icons.headset_mic_outlined,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: product == null
          ? const Center(
              child: Text(
                'Tidak ada produk untuk di-checkout.\nSilakan tambahkan produk ke keranjang dulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6F7A74),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ================== ALAMAT PENGIRIMAN ==================
                      _buildAddressCard(),

                      const SizedBox(height: 14),

                      // ================== INFO TOKO + PRODUK ==================
                      _buildStoreAndProductCard(product),

                      const SizedBox(height: 14),

                      // ================== PENGIRIMAN ==================
                      _buildShippingCard(),

                      const SizedBox(height: 14),

                      // ================== METODE PEMBAYARAN ==================
                      _buildPaymentCard(),

                      const SizedBox(height: 14),

                      // ================== RINGKASAN PESANAN ==================
                      _buildOrderSummaryCard(product),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // ================== TOTAL + SLIDER ==================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOTAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F7A74),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(product.price)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // SLIDER
                      _buildSwipeSlider(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ================== WIDGET: ALAMAT ==================
  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
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
          const Icon(
            Icons.place_outlined,
            color: primaryColor,
            size: 24,
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
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Rafael Sinaga\nJl. Mawar No. 23, Medan\nSumatera Utara, 20112',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F5A5E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              // TODO: buka halaman pilih / edit alamat
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.5)),
              ),
              child: const Text(
                'Ubah',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================== WIDGET: TOKO + PRODUK ==================
  Widget _buildStoreAndProductCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BARIS TOKO
          Row(
            children: [
              const Icon(
                Icons.storefront_rounded,
                color: primaryColor,
                size: 20,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Overall Store',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
              Text(
                'Kode: #C0238473',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // PRODUK
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    product.imagePath,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
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
                        'x1 • Rp ${_formatPrice(product.price)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6F7A74),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6F7A74),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== WIDGET: PENGIRIMAN ==================
  Widget _buildShippingCard() {
    final methods = [
      'JNE - Reguler (2–4 hari kerja)',
      'J&T Express (1–3 hari kerja)',
      'GoSend - Instant (1 jam)',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pengiriman',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < methods.length; i++)
            Column(
              children: [
                RadioListTile<int>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: i,
                  groupValue: _selectedShipping,
                  activeColor: primaryColor,
                  title: Text(
                    methods[i],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF243036),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _selectedShipping = val ?? 0;
                    });
                  },
                ),
                if (i != methods.length - 1)
                  const Divider(
                    height: 8,
                    color: Color(0xFFE3ECF4),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ================== WIDGET: PEMBAYARAN ==================
  Widget _buildPaymentCard() {
    final methods = [
      'PayLater',
      'DANA',
      'Bayar di Tempat (COD)',
      'OVO',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < methods.length; i++)
            Column(
              children: [
                RadioListTile<int>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: i,
                  groupValue: _selectedPayment,
                  activeColor: primaryColor,
                  title: Text(
                    methods[i],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF243036),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _selectedPayment = val ?? 0;
                    });
                  },
                ),
                if (i != methods.length - 1)
                  const Divider(
                    height: 8,
                    color: Color(0xFFE3ECF4),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ================== WIDGET: RINGKASAN ==================
  Widget _buildOrderSummaryCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    product.imagePath,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Harga: Rp ${_formatPrice(product.price)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6F7A74),
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  'x1',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== WIDGET: SLIDER ==================
  Widget _buildSwipeSlider() {
    const double thumbSize = 42;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxThumbX = maxWidth - thumbSize;

        final double thumbX = _sliderValue * maxThumbX;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE3ECF4),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Stack(
                children: [
                  // TEKS DI TENGAH
                  Center(
                    child: Text(
                      _sliderValue >= 1.0
                          ? 'Sedang memproses...'
                          : 'Swipe untuk melanjutkan',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),

                  // THUMB
                  Positioned(
                    left: thumbX,
                    top: 3,
                    bottom: 3,
                    child: GestureDetector(
                      onHorizontalDragStart: (_) {
                        setState(() {
                          _isSliding = true;
                        });
                      },
                      onHorizontalDragUpdate: (details) {
                        final localX =
                            (thumbX + details.delta.dx).clamp(0.0, maxThumbX);
                        setState(() {
                          _sliderValue = localX / maxThumbX;
                        });
                      },
                      onHorizontalDragEnd: (_) {
                        setState(() {
                          _isSliding = false;
                        });

                        if (_sliderValue > 0.85) {
                          setState(() {
                            _sliderValue = 1.0;
                          });
                          _handleConfirmPayment();
                        } else {
                          setState(() {
                            _sliderValue = 0.0;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: thumbSize,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _isSliding
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dengan men-swipe "Konfirmasi Pesanan", Anda menyetujui syarat dan ketentuan yang berlaku.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6F7A74),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================== UTIL ==================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.withOpacity(0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _formatPrice(num price) {
    final val = price.round();
    final s = val.toString();
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
}
