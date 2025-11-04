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

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedMethod = PaymentMethod.paylater;

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF124170),
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Keranjang kosong.'))
          : Column(
              children: [
                // --- Daftar produk yang dibeli ---
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final product = cart.items[index];
                      return CheckoutItem(product: product);
                    },
                  ),
                ),

                // --- Pemilihan metode pembayaran ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Metode Pembayaran',
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

                // --- Bagian total & tombol konfirmasi ---
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
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
                      ElevatedButton(
                        onPressed: () {
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
                                  'Pesanan berhasil dibuat menggunakan $paymentName!'),
                            ),
                          );
                          cart.clearCart();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF124170),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Konfirmasi Pembayaran',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
