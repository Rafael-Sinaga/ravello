// lib/pages/detail_product.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'checkout_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailProduct extends StatefulWidget {
  final Product product;

  const DetailProduct({super.key, required this.product});

  @override
  State<DetailProduct> createState() => _DetailProductState();
}

class _DetailProductState extends State<DetailProduct> {
  String? selectedSize;
  bool _isFavorited = false;
  bool _isBoosted = false;
  late String _favKey;

  final List<_Review> _reviews = [
    _Review(
      userName: 'Rafael',
      rating: 4.5,
      comment: 'Kualitas bahan bagus, jahitan rapi. Dipakai nonton bola nyaman banget.',
      dateLabel: '2 hari lalu',
    ),
    _Review(
      userName: 'Grace',
      rating: 5.0,
      comment: 'Warnanya sesuai foto, packing rapi, pengiriman juga cepat.',
      dateLabel: '5 hari lalu',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _favKey =
        '${widget.product.name}_${widget.product.price}_${widget.product.imagePath}';
    _loadFavorite();
    _checkBoostStatus();
  }

  Future<void> _checkBoostStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs
        .getStringList('boosted_product_ids')
        ?.map((e) => int.tryParse(e))
        .whereType<int>()
        .toSet();
    if (ids != null &&
        widget.product.productId != null &&
        ids.contains(widget.product.productId)) {
      setState(() => _isBoosted = true);
    }
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorited =
          prefs.getStringList('favorites')?.contains(_favKey) ?? false;
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    setState(() {
      if (_isFavorited) {
        favs.remove(_favKey);
        _isFavorited = false;
      } else {
        favs.add(_favKey);
        _isFavorited = true;
      }
    });
    await prefs.setStringList('favorites', favs);
  }

  String get _storeName =>
      widget.product.storeName?.isNotEmpty == true
          ? widget.product.storeName!
          : 'Usaha Lokal';

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        widget.product.discount != null && widget.product.discount! > 0;
    final discountedPrice = hasDiscount
        ? widget.product.price -
            (widget.product.price * (widget.product.discount! / 100))
        : widget.product.price;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF124170)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            color: Color(0xFF124170),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // IMAGE
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: widget.product.imagePath.startsWith('http')
                      ? Image.network(widget.product.imagePath,
                          height: 200, fit: BoxFit.contain)
                      : Image.asset(widget.product.imagePath,
                          height: 200, fit: BoxFit.contain),
                ),
                if (_isBoosted)
                  Positioned(top: 0, right: 0, child: _badge('Produk Unggulan')),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Color(0xFF124170),
            ),
          ),
          const SizedBox(height: 6),
          if (hasDiscount)
            Text(
              'Rp ${_formatPrice(widget.product.price)}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                decoration: TextDecoration.lineThrough,
                fontFamily: 'Poppins',
              ),
            ),
          Text(
            'Rp ${_formatPrice(discountedPrice)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF124170),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Tentang Usaha',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE5EDFF), Color(0xFFF5F7FF)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.storefront_rounded,
                    color: Color(0xFF124170)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _storeName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ]),
              const SizedBox(height: 6),
              const Text(
                'Usaha lokal yang dikelola secara mandiri oleh pelaku UMKM. '
                'Setiap pembelianmu membantu usaha ini terus berkembang.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: Color(0xFF4B5563),
                  fontFamily: 'Poppins',
                ),
              ),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ),

      // CTA (TIDAK MERUSAK YANG ADA)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(widget.product, size: selectedSize);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk ditambahkan ke keranjang'),
                      backgroundColor: Color(0xFF124170),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF124170),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(widget.product, size: selectedSize);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF124170)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Beli Sekarang',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF124170),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.deepOrange,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  String _formatPrice(num price) {
    final s = price.round().toString();
    final buffer = StringBuffer();
    int c = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      c++;
      if (c == 3 && i != 0) {
        buffer.write('.');
        c = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }
}

class _Review {
  final String userName;
  final double rating;
  final String comment;
  final String dateLabel;

  _Review({
    required this.userName,
    required this.rating,
    required this.comment,
    required this.dateLabel,
  });
}
