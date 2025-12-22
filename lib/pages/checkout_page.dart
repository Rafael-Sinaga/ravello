// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/address_provider.dart';
import 'order_page.dart';
import 'edit_address_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  // ==========================================================
  // MODE STARLING (PICKUP)
  // ==========================================================
  // Untuk sekarang dibuat TRUE agar WORK & bisa dipakai starling
  // NANTI bisa diganti dari cart / seller / product
  final bool isPickupOrder = true;

  int _selectedShipping = 0;
  int _selectedPayment = 2; // COD default (aman untuk starling)

  double _sliderValue = 0.0;

  // ==========================================================
  // CONFIRM
  // ==========================================================
  void _handleConfirmPayment() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk untuk diproses.'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    // ⚠️ LOGIC LAMA — TIDAK DIUBAH
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.addOrderFromCartItems(cart.items);

    cart.clearCart();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrderPage()),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dukung Usaha Lokal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
      body: cart.items.isEmpty
          ? const Center(
              child: Text(
                'Tidak ada pesanan yang sedang diproses.',
                textAlign: TextAlign.center,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildImpactCard(),
                      const SizedBox(height: 14),
                      _buildAddressCard(),
                      const SizedBox(height: 14),
                      _buildShippingCard(),
                      const SizedBox(height: 14),
                      _buildPaymentCard(),
                      const SizedBox(height: 14),
                      _buildOrderSummaryCard(cart),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
                _buildBottomConfirm(cart),
              ],
            ),
    );
  }

  // ==========================================================
  // IMPACT CARD
  // ==========================================================
  Widget _buildImpactCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.storefront_rounded, color: primaryColor, size: 26),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pesanan akan diteruskan langsung ke penjual.\nUsaha kecil mulai menyiapkan pesanan setelah kamu konfirmasi.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // ADDRESS
  // ==========================================================
  Widget _buildAddressCard() {
    if (isPickupOrder) {
      return _card(
        title: 'Pengambilan Pesanan',
        icon: Icons.storefront_outlined,
        child: const Text(
          'Pesanan diambil langsung di lokasi penjual.\nAlamat pengiriman tidak diperlukan.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      );
    }

    final addr = Provider.of<AddressProvider>(context).address;

    return _card(
      title: 'Alamat Pengiriman',
      icon: Icons.place_outlined,
      trailing: TextButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditAddressPage()),
          );
        },
        child: const Text(
          'Ubah',
          style: TextStyle(fontSize: 11, color: primaryColor),
        ),
      ),
      child: Text(
        '${addr.name}\n${addr.address}\n${addr.city}\nTelp: ${addr.phone}',
        style: const TextStyle(fontSize: 12, height: 1.4),
      ),
    );
  }

  // ==========================================================
  // SHIPPING
  // ==========================================================
  Widget _buildShippingCard() {
    if (isPickupOrder) {
      return _card(
        title: 'Metode Pengiriman',
        icon: Icons.local_shipping_outlined,
        child: const Text(
          'Tidak menggunakan jasa pengiriman.\nPesanan diambil langsung.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      );
    }

    final methods = [
      'JNE Reguler • 2–4 hari',
      'J&T Express • 1–3 hari',
      'GoSend Instant • ±1 jam',
    ];

    return _card(
      title: 'Pengiriman',
      icon: Icons.local_shipping_outlined,
      child: Column(
        children: List.generate(methods.length, (i) {
          return RadioListTile<int>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: i,
            groupValue: _selectedShipping,
            activeColor: primaryColor,
            title: Text(methods[i], style: const TextStyle(fontSize: 12)),
            onChanged: (v) => setState(() => _selectedShipping = v ?? 0),
          );
        }),
      ),
    );
  }

  // ==========================================================
  // PAYMENT
  // ==========================================================
  Widget _buildPaymentCard() {
    final methods = isPickupOrder
        ? ['COD (Bayar di Tempat)']
        : [
            'PayLater',
            'DANA',
            'COD (Bayar di Tempat)',
            'OVO',
            'Transfer Bank',
          ];

    return _card(
      title: 'Metode Pembayaran',
      icon: Icons.account_balance_wallet_outlined,
      child: Column(
        children: List.generate(methods.length, (i) {
          return RadioListTile<int>(
            dense: true,
            contentPadding: EdgeInsets.zero,
            value: i,
            groupValue: _selectedPayment,
            activeColor: primaryColor,
            title: Text(methods[i], style: const TextStyle(fontSize: 12)),
            onChanged: (v) => setState(() => _selectedPayment = v ?? 0),
          );
        }),
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================
  Widget _buildOrderSummaryCard(CartProvider cart) {
    return _card(
      title: 'Produk yang Kamu Dukung',
      icon: Icons.shopping_bag_outlined,
      child: Column(
        children: cart.items.map((ci) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${ci.product.name} x${ci.quantity}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  'Rp ${ci.product.price * ci.quantity}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ==========================================================
  // BOTTOM
  // ==========================================================
  Widget _buildBottomConfirm(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: const BoxDecoration(color: Colors.white),
      child: GestureDetector(
        onHorizontalDragEnd: (_) => _handleConfirmPayment(),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Geser untuk membantu penjual memproses pesanan',
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CARD
  // ==========================================================
  Widget _card({
    required String title,
    required IconData icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
