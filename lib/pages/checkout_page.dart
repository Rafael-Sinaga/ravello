// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/checkout_item.dart';
import '../widgets/payment_method_selector.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  PaymentMethod _selectedMethod = PaymentMethod.paylater;
  String _selectedDelivery = 'JNE';
  double _dragPosition = 0.0;
  bool _confirmed = false;

  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runSmoothRebound() {
    final start = _dragPosition;
    _slideAnimation =
        Tween<double>(begin: start, end: 0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    ))
          ..addListener(() {
            setState(() {
              _dragPosition = _slideAnimation.value;
            });
          });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF124170),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Keranjang kosong.'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // === Alamat Pengiriman ===
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alamat Pengiriman',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF124170),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Rafael Sinaga\nJl. Mawar No. 23, Medan\nSumatera Utara, 20112',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === Metode Pengiriman ===
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pengiriman',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF124170),
                            ),
                          ),
                          const SizedBox(height: 8),
                          RadioListTile<String>(
                            value: 'JNE',
                            groupValue: _selectedDelivery,
                            onChanged: (v) => setState(() => _selectedDelivery = v!),
                            title: const Text('JNE - Reguler (2-4 hari)'),
                          ),
                          RadioListTile<String>(
                            value: 'J&T',
                            groupValue: _selectedDelivery,
                            onChanged: (v) => setState(() => _selectedDelivery = v!),
                            title: const Text('J&T Express (1-3 hari)'),
                          ),
                          RadioListTile<String>(
                            value: 'GoSend',
                            groupValue: _selectedDelivery,
                            onChanged: (v) => setState(() => _selectedDelivery = v!),
                            title: const Text('GoSend - Instant (1 jam sampai)'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === Metode Pembayaran ===
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF124170),
                            ),
                          ),
                          const SizedBox(height: 8),
                          PaymentMethodSelector(
                            selected: _selectedMethod,
                            onChanged: (method) {
                              setState(() => _selectedMethod = method);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // === Ringkasan Pesanan ===
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ringkasan Pesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF124170),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cart.items.length,
                            itemBuilder: (context, index) {
                              final product = cart.items[index];
                              return CheckoutItem(product: product);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // === Total & Slide Button ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Total: Rp ${cart.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),

                          // === Tombol geser dengan animasi halus ===
                          GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              setState(() {
                                _dragPosition += details.delta.dx;
                                if (_dragPosition < 0) _dragPosition = 0;
                                if (_dragPosition > screenWidth - 100) {
                                  _dragPosition = screenWidth - 100;
                                  _confirmed = true;
                                }
                              });
                            },
                            onHorizontalDragEnd: (_) {
                              if (_confirmed) {
                                _onConfirm(cart, context);
                              } else {
                                _runSmoothRebound();
                              }
                            },
                            child: Stack(
                              children: [
                                // Background Track
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDDF4E7),
                                    borderRadius: BorderRadius.circular(40),
                                    border: Border.all(
                                      color: const Color(0x806F7A74),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Geser untuk konfirmasi pembayaran',
                                    style: TextStyle(
                                      color: Color(0xFF6F7A74),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Tombol slider dengan transisi lembut
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeOutExpo,
                                  left: _dragPosition,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF3A6188),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xFFDDF4E7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _onConfirm(CartProvider cart, BuildContext context) {
    String paymentName;
    switch (_selectedMethod) {
      case PaymentMethod.paylater:
        paymentName = 'PayLater';
        break;
      case PaymentMethod.dana:
        paymentName = 'Dana';
        break;
      case PaymentMethod.cod:
        paymentName = 'Bayar di tempat';
        break;
      case PaymentMethod.ovo:
        paymentName = 'OVO';
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pesanan dikonfirmasi!\nPembayaran: $paymentName\nPengiriman: $_selectedDelivery',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    cart.clearCart();
    Navigator.pop(context);
  }
}
