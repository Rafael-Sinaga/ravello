import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart'; // <--- tambahkan ini

class DetailProduct extends StatelessWidget {
  final Product product;

  const DetailProduct({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = product.discount != null && product.discount! > 0;
    final double discountedPrice = hasDiscount
        ? product.price - (product.price * product.discount! / 100)
        : product.price;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Bagian atas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE8EEF3),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF124170)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        product.name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFE8EEF3),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Color(0xFF124170)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur bagikan belum diimplementasikan'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Konten utama
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar produk
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 250),
                            child: Image.asset(
                              product.imagePath,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox(
                                  height: 250,
                                  child: Center(
                                    child: Icon(Icons.broken_image,
                                        size: 100, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: index == 0
                                      ? const Color(0xFF124170)
                                      : Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Nama produk
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Harga dan diskon
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Rp ${discountedPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF124170),
                            ),
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '-${product.discount!.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    if (hasDiscount)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Deskripsi
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Tombol bawah
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(0, -1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Tambah ke Keranjang
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final cart =
                            Provider.of<CartProvider>(context, listen: false);
                        cart.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF124170),
                            content: Text(
                              '${product.name} berhasil ditambahkan ke keranjang!',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF124170),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Tombol Checkout
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final cart =
                            Provider.of<CartProvider>(context, listen: false);
                        cart.addToCart(product);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CheckoutPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFB0C0CF),
                        side: const BorderSide(
                            color: Color(0xFF124170), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Checkout',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF124170),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
