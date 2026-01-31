// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/address_provider.dart';
import '../services/order_service.dart';
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
  // MODE PICKUP
  // ==========================================================
  final bool isPickupOrder = true;

  int _selectedShipping = 0;
  int _selectedPayment = -1; // 🔒 WAJIB pilih payment
  double _sliderValue = 0.0;

  bool get _isPaymentSelected => _selectedPayment >= 0;

  // ==========================================================
  // CONFIRM PAYMENT
  // ==========================================================
  Future<void> _handleConfirmPayment() async {
    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada produk')),
      );
      return;
    }

    final orderItems = cart.items
        .map((c) => {
              "product_id": c.product.productId,
              "quantity": c.quantity,
            })
        .toList();

    try {
      final result = await OrderService.createOrder(
        orderItems: orderItems,
        paymentMethod: "COD",
        shippingAddress: isPickupOrder ? "Pickup" : "Delivery",
      );

      if (result['success'] == true) {
        context.read<OrderProvider>().addOrderFromCartItems(cart.items, paymentMethod: 'COD',);
        cart.clearCart();

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderPage()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat!'),
            backgroundColor: primaryColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal membuat pesanan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
          ? const Center(child: Text('Tidak ada pesanan.'))
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
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                _buildBottomConfirm(),
              ],
            ),
    );
  }

  // ==========================================================
  // IMPACT
  // ==========================================================
  Widget _buildImpactCard() {
    return _card(
      title: 'Dukung Usaha Lokal',
      icon: Icons.storefront_rounded,
      child: const Text(
        'Pesanan akan diteruskan langsung ke penjual.\n'
        'Usaha kecil mulai menyiapkan pesanan setelah kamu konfirmasi.',
        style: TextStyle(fontSize: 12, height: 1.4),
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
          'Pesanan diambil langsung di lokasi penjual.\n'
          'Alamat pengiriman tidak diperlukan.',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
      );
    }

    final addr = context.watch<AddressProvider>().address;

    return _card(
      title: 'Alamat Pengiriman',
      icon: Icons.place_outlined,
      trailing: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditAddressPage()),
        ),
        child: const Text('Ubah', style: TextStyle(fontSize: 11)),
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
    return _card(
      title: 'Metode Pengiriman',
      icon: Icons.local_shipping_outlined,
      child: const Text(
        'Tidak menggunakan jasa pengiriman.\nPesanan diambil langsung.',
        style: TextStyle(fontSize: 12, height: 1.4),
      ),
    );
  }

  // ==========================================================
  // PAYMENT
  // ==========================================================
  Widget _buildPaymentCard() {
    final methods = ['COD (Bayar di Tempat)'];

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
            onChanged: (v) => setState(() => _selectedPayment = v ?? -1),
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
  // SLIDER CHECKOUT (FINAL)
  // ==========================================================
  Widget _buildBottomConfirm() {
    final screenWidth = MediaQuery.of(context).size.width;

    const double horizontalPadding = 16;
    const double handleSize = 56;

    final double trackWidth =
        screenWidth - (horizontalPadding * 2);
    final double maxSlide = trackWidth - handleSize;

    return Container(
      padding: const EdgeInsets.fromLTRB(
          horizontalPadding, 12, horizontalPadding, 18),
      color: Colors.white,
      child: Container(
        height: 58,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isPaymentSelected
              ? const Color(0xFFE6EEF6)
              : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            // ================= TEKS (AMAN, TIDAK KETUTUP) =================
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: handleSize + 12,
                ),
                child: Center(
                  child: Text(
                    _isPaymentSelected
                        ? 'Geser untuk membantu penjual memproses pesanan'
                        : 'Pilih metode pembayaran terlebih dahulu',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: _isPaymentSelected
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),

            // ================= HANDLE BULAT =================
            Positioned(
              left: _sliderValue,
              top: 1,
              bottom: 1,
              child: GestureDetector(
                onHorizontalDragUpdate: _isPaymentSelected
                    ? (details) {
                        setState(() {
                          _sliderValue += details.delta.dx;
                          _sliderValue =
                              _sliderValue.clamp(0.0, maxSlide);
                        });
                      }
                    : null,
                onHorizontalDragEnd: _isPaymentSelected
                    ? (_) {
                        if (_sliderValue > maxSlide * 0.85) {
                          _handleConfirmPayment();
                        } else {
                          setState(() => _sliderValue = 0);
                        }
                      }
                    : null,
                child: Container(
                  width: handleSize,
                  height: handleSize,
                  decoration: BoxDecoration(
                    color: _isPaymentSelected
                        ? primaryColor
                        : Colors.grey,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CARD HELPER
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
