// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';
import '../pages/detail_product.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../widgets/navbar.dart';
import '../pages/notification_page.dart';
import '../services/auth_service.dart';
import '../pages/settings_page.dart';
import '../services/product_service.dart';
import 'search_result_page.dart';
import '../pages/umkm_map_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _productError;

  Set<int> _boostedProductIds = {};
  final TextEditingController _searchController = TextEditingController();

  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

Future<void> _loadProducts() async {
  print('LOAD PRODUCTS START');

  setState(() {
    _isLoadingProducts = true;
    _productError = null;
  });

  try {
    final list = await ProductService.fetchProducts();

    print('PRODUCT LIST LENGTH: ${list.length}');
    if (list.isNotEmpty) {
      print('FIRST PRODUCT NAME: ${list.first.name}');
      print('FIRST PRODUCT IMAGE: ${list.first.imagePath}');
    }

    final prefs = await SharedPreferences.getInstance();
    final boostedStrings =
        prefs.getStringList('boosted_product_ids') ?? <String>[];
    final boostedIds =
        boostedStrings.map((e) => int.tryParse(e)).whereType<int>().toSet();

    list.sort((a, b) {
      final aBoosted =
          a.productId != null && boostedIds.contains(a.productId);
      final bBoosted =
          b.productId != null && boostedIds.contains(b.productId);
      if (aBoosted == bBoosted) return 0;
      return aBoosted ? -1 : 1;
    });

    if (!mounted) return;

    setState(() {
      _products = list;
      _boostedProductIds = boostedIds;
      _isLoadingProducts = false;
    });

    print('SETSTATE FINISHED, PRODUCT COUNT: ${_products.length}');
  } catch (e) {
    print('ERROR LOAD PRODUCT: $e');

    if (!mounted) return;
    setState(() {
      _productError = 'Gagal memuat produk UMKM. Coba lagi.';
      _isLoadingProducts = false;
    });
  }
}


  void _openSearch(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchResultPage(
          query: query,
          allProducts: _products,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD HOME PAGE');
print('PRODUCT COUNT: ${_products.length}');
print('IS LOADING: $_isLoadingProducts');
    final user = AuthService.currentUser;
    final orderProvider = Provider.of<OrderProvider>(context);
    final hasPendingOrders =
        orderProvider.orders.any((o) => o.status != 'Selesai');

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      bottomNavigationBar: const Navbar(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ================= HEADER =================
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF124170).withOpacity(0.06),
                        const Color(0xFF4A688A).withOpacity(0.02),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/images/Profile.png',
                          width: 45,
                          height: 45,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Halo, ${user?.name ?? "Pengguna"}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF102A43),
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Terima kasih telah mendukung UMKM 🇮🇩',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF7B8794),
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: Color(0xFF124170)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationPage(
                                    orders: orderProvider.orders,
                                  ),
                                ),
                              );
                            },
                          ),
                          if (hasPendingOrders)
                            Positioned(
                              right: 10,
                              top: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEC4A3F),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined,
                            color: Color(0xFF124170)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= SEARCH =================
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: _openSearch,
                    decoration: const InputDecoration(
                      hintText: 'Cari produk UMKM yang kamu butuhkan',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF124170)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= MAP UMKM PREVIEW =================
                InkWell(
                  borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UMKMMapPage(),
                        ),
                      );
                    },

                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        children: [
                          Container(
                            color: const Color(0xFFE9F0FA),
                            child: const Center(
                              child: Icon(
                                Icons.map_outlined,
                                size: 64,
                                color: Color(0xFF9FB3C8),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.05),
                                  Colors.black.withOpacity(0.45),
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'UMKM di Sekitarmu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Temukan penjual aktif di sekitar lokasi kamu',
                                  style: TextStyle(
                                    color: Color(0xFFE5E7EB),
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Text(
                                'Lihat Peta',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF124170),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// ================= PRODUK =================
                const Text(
                  'Pilihan UMKM Hari Ini',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF124170),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Produk dari pelaku usaha lokal yang aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7B8794),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 16),

                _isLoadingProducts
  ? const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: CircularProgressIndicator(
          color: Color(0xFF124170),
        ),
      ),
    )
  : _products.isEmpty
      ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'DEBUG: Produk kosong',
              style: TextStyle(fontSize: 14),
            ),
          ),
        )
      : GridView.builder(

                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _products.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.80,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          final isBoosted =
                              product.productId != null &&
                                  _boostedProductIds
                                      .contains(product.productId);

                          return GestureDetector(
                            onTapDown: (_) =>
                                setState(() => _pressedIndex = index),
                            onTapUp: (_) =>
                                setState(() => _pressedIndex = null),
                            onTapCancel: () =>
                                setState(() => _pressedIndex = null),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailProduct(product: product),
                                ),
                              );
                            },
                            child: AnimatedScale(
                              scale:
                                  _pressedIndex == index ? 0.97 : 1.0,
                              duration:
                                  const Duration(milliseconds: 120),
                              curve: Curves.easeOut,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withOpacity(0.06),
                                          blurRadius: 14,
                                          offset:
                                              const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(14),
                                            ),
                                            child: Image.network(
                                              product.imagePath,
                                              fit: BoxFit.contain,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product.name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style:
                                                    const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  fontFamily:
                                                      'Poppins',
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                'Usaha lokal • Produksi mandiri',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color:
                                                      Color(0xFF7B8794),
                                                  fontFamily:
                                                      'Poppins',
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Rp ${_formatPrice(product.price)}',
                                                style:
                                                    const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color:
                                                      Color(0xFF124170),
                                                  fontFamily:
                                                      'Poppins',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isBoosted)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 3),
                                        decoration: BoxDecoration(
                                          color:
                                              const Color(0xFFEFF6FF),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                            color:
                                                const Color(0xFF124170),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Didukung Platform',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF124170),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _formatPrice(num price) {
  final s = price.round().toString();
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
