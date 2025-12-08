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
import 'search_result_page.dart'; // <-- TAMBAHAN: halaman hasil search

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPromo = 0;
  final PageController _promoController = PageController();
  Timer? _promoTimer;
  String? selectedCategory;

  // ===== produk dari backend =====
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _productError;

  // ===== daftar produk yang di-boost (id dari SharedPreferences) =====
  Set<int> _boostedProductIds = {};

  // ===== controller search =====
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _loadProducts();
  }

  void _startAutoScroll() {
    _promoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_promoController.hasClients) {
        int nextPage = (currentPromo + 1) % 3;
        _promoController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String _mapProductError(Object error) {
    final msg = error.toString();

    final lower = msg.toLowerCase();
    if (lower.contains('timeout')) {
      return 'Koneksi ke server lambat. Coba lagi beberapa saat.';
    }

    if (msg.contains('Status: 404')) {
      return 'Produk belum tersedia atau endpoint produk tidak ditemukan (404).';
    }

    if (lower.contains('bukan json valid') ||
        lower.contains('html') && lower.contains('server')) {
      return 'Data produk dari server tidak dapat dibaca. Coba lagi beberapa saat.';
    }

    return 'Gagal memuat produk. Coba lagi beberapa saat.';
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoadingProducts = true;
      _productError = null;
    });

    try {
      // ambil semua produk dari backend
      final list = await ProductService.fetchProducts();

      // ambil id produk yang di-boost dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final boostedStrings =
          prefs.getStringList('boosted_product_ids') ?? <String>[];
      final boostedIds =
          boostedStrings.map((e) => int.tryParse(e)).whereType<int>().toSet();

      // sort: produk boosted di urutan paling atas
      list.sort((a, b) {
        final aBoosted =
            a.productId != null && boostedIds.contains(a.productId);
        final bBoosted =
            b.productId != null && boostedIds.contains(b.productId);

        if (aBoosted == bBoosted) return 0;
        return aBoosted ? -1 : 1; // true duluan
      });

      if (!mounted) return;
      setState(() {
        _products = list;
        _boostedProductIds = boostedIds;
        _isLoadingProducts = false;
      });

      // debug dikit kalau mau lihat
      // print('BOOSTED IDs: $_boostedProductIds');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _productError = _mapProductError(e);
        _isLoadingProducts = false;
      });
    }
  }

  void _openSearch(String rawQuery) {
    final query = rawQuery.trim();
    if (query.isEmpty) return;

    if (_isLoadingProducts || _products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Produk belum siap dicari. Coba lagi setelah produk selesai dimuat.',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
        ),
      );
      return;
    }

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
    _promoTimer?.cancel();
    _promoController.dispose();
    _searchController.dispose(); // <-- dispose controller search
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    print("DEBUG: User di HomePage => ${user?.name}, ${user?.email}");
    final orderProvider = Provider.of<OrderProvider>(context);
    final cart = Provider.of<CartProvider>(context, listen: false);

    final hasPendingOrders = orderProvider.orders.any(
  (o) => o.status != 'Selesai',
);


    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      bottomNavigationBar: const Navbar(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadProducts,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER DALAM CARD
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF124170).withOpacity(0.06),
                          const Color(0xFF4A688A).withOpacity(0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
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
                                'Selamat datang kembali 👋',
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
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NotificationPage(
                                      orders: orderProvider.orders,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Color(0xFF124170),
                              ),
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
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SettingsPage(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Color(0xFF124170),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // SEARCH BAR (PILL)
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
                      decoration: InputDecoration(
                        hintText: 'Cari barang yang anda inginkan',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9AA5B1),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        border: InputBorder.none,
                        icon: const Icon(Icons.search, color: Color(0xFF124170)),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: Color(0xFF124170),
                          ),
                          onPressed: () {
                            _openSearch(_searchController.text);
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // KATEGORI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF124170),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7B8794),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 100,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          _buildCategoryCircle(
                              Icons.directions_walk, 'Trail'),
                          _buildCategoryCircle(Icons.remove_red_eye, 'Kacamata'),
                          _buildCategoryCircle(
                              Icons.shopping_bag_outlined, 'Busana'),
                          _buildCategoryCircle(
                              Icons.phone_android, 'Elektronik'),
                          _buildCategoryCircle(Icons.home_outlined, 'Dekorasi'),
                          _buildCategoryCircle(Icons.kitchen, 'Perabot'),
                          _buildCategoryCircle(Icons.watch, 'Jam Tangan'),
                          _buildCategoryCircle(Icons.spa, 'Kecantikan'),
                          _buildCategoryCircle(
                              Icons.local_florist, 'Tanaman Hias'),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // PROMO CAROUSEL
                  SizedBox(
                    height: 140,
                    child: PageView(
                      controller: _promoController,
                      onPageChanged: (index) {
                        setState(() => currentPromo = index);
                      },
                      children: [
                        _buildPromoCard(
                          'assets/images/sepatu.png',
                          'Diskon Spesial',
                          'Produk dengan harga spesial minggu ini!',
                        ),
                        _buildPromoCard(
                          'assets/images/Gelang_rajut.png',
                          'Promo Aksesoris',
                          'Temukan aksesori menarik dengan harga hemat!',
                        ),
                        _buildPromoCard(
                          'assets/images/Jersey.png',
                          'Fashion Terbaru',
                          'Tampil sporty dan stylish dengan produk lokal!',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // DOTS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: currentPromo == index ? 20 : 6,
                        decoration: BoxDecoration(
                          color: currentPromo == index
                              ? const Color(0xFF124170)
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PRODUK UNGGULAN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Produk Unggulan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF124170),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Lihat semua',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7B8794),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // === STATE PRODUK ===
                  if (_isLoadingProducts)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(
                          color: Color(0xFF124170),
                        ),
                      ),
                    )
                  else if (_productError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Text(
                            _productError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _loadProducts,
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    )
                  else if (_products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Belum ada produk.\nSilakan tambahkan produk di halaman penjual.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.80,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _products.length,
                      itemBuilder: (context, index) {
                        final product = _products[index];
                        final hasDiscount =
                            product.discount != null && product.discount! > 0;
                        final num discountedPrice = hasDiscount
                            ? product.price -
                                (product.price * (product.discount! / 100))
                            : product.price;

                        final bool isBoosted = product.productId != null &&
                            _boostedProductIds.contains(product.productId);

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    DetailProduct(product: product),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Hero(
                                      tag: product.imagePath,
                                      child: ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(14),
                                        ),
                                        child: product.imagePath
                                                .toString()
                                                .startsWith('http')
                                            ? Image.network(
                                                product.imagePath,
                                                height: 90,
                                                width: double.infinity,
                                                fit: BoxFit.contain,
                                                filterQuality:
                                                    FilterQuality.medium,
                                                errorBuilder: (_, __, ___) =>
                                                    const Icon(
                                                  Icons.broken_image,
                                                  size: 40,
                                                ),
                                              )
                                            : Image.asset(
                                                product.imagePath,
                                                height: 90,
                                                width: double.infinity,
                                                fit: BoxFit.contain,
                                                filterQuality:
                                                    FilterQuality.medium,
                                              ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              product.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (hasDiscount) ...[
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Rp ${_formatPrice(product.price)}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          fontFamily:
                                                              'Poppins',
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        '-${product.discount!.toStringAsFixed(0)}%',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily:
                                                              'Poppins',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                ],
                                                Text(
                                                  'Rp ${_formatPrice(discountedPrice)}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF124170),
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () {
                                                  cart.addToCart(product);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        '${product.name} ditambahkan ke keranjang',
                                                        style: const TextStyle(
                                                            fontFamily:
                                                                'Poppins'),
                                                      ),
                                                      backgroundColor:
                                                          const Color(
                                                              0xFF124170),
                                                      action: SnackBarAction(
                                                        label: 'Lihat',
                                                        textColor: Colors.white,
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/cart');
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                style:
                                                    OutlinedButton.styleFrom(
                                                  side: const BorderSide(
                                                      color:
                                                          Color(0xFF124170)),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 6,
                                                      horizontal: 8),
                                                ),
                                                icon: const Icon(
                                                  Icons.shopping_bag_outlined,
                                                  size: 14,
                                                  color: Color(0xFF124170),
                                                ),
                                                label: const Text(
                                                  'Tambah',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontFamily: 'Poppins',
                                                    color: Color(0xFF124170),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // BADGE BOOST
                              if (isBoosted)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.orange.shade400,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.local_fire_department_rounded,
                                          size: 12,
                                          color: Colors.deepOrange,
                                        ),
                                        SizedBox(width: 3),
                                        Text(
                                          'Boosted',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.deepOrange,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
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
      ),
    );
  }

  // ================== HELPER KATEGORI ==================

  Widget _buildCategoryCircle(IconData icon, String label) {
    final isSelected = selectedCategory == label;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedCategory = label;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kategori $label dipilih')),
          );
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF124170) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF124170)
                        : Colors.grey.shade300,
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF124170),
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HELPER PROMO CARD ==================

  Widget _buildPromoCard(String imagePath, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promo "$title" diklik')),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF124170),
              const Color(0xFF4F709C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(
                imagePath,
                width: 110,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFE5E7EB),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================== HELPER FORMAT HARGA ==================

  String _formatPrice(num price) {
    final int value = price.round();
    final s = value.toString();
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
