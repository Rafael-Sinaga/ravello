import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../pages/detail_product.dart';
import '../providers/cart_provider.dart';
import '../widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Product> productList = [
    Product(
      name: 'Gelang Rajut',
      price: 300000,
      imagePath: 'assets/images/Gelang_rajut.png',
      description: 'Gelang rajut warna-warni handmade cocok untuk segala usia.',
    ),
    Product(
      name: 'Jersey',
      price: 120000,
      imagePath: 'assets/images/Jersey.png',
      description: 'Jersey premium bahan halus dengan desain sporty elegan.',
    ),
    Product(
      name: 'Sepatu Abibas',
      price: 20000,
      imagePath: 'assets/images/Sepatu.png',
      description: 'Sepatu lokal gaya kasual dengan harga super terjangkau.',
    ),
    Product(
      name: 'Rolex KW',
      price: 300000,
      imagePath: 'assets/images/Rolex_KW.png',
      description: 'Jam tangan elegan, kualitas tinggi dengan harga ramah.',
    ),
    Product(
      name: 'Sepatu Kulit Lokal',
      price: 185000,
      imagePath: 'assets/images/sepatu.png',
      description: 'Sepatu kulit asli buatan pengrajin lokal berkualitas tinggi.',
    ),
  ];

  int currentPromo = 0;
  final PageController _promoController = PageController();
  Timer? _promoTimer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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

  @override
  void dispose() {
    _promoTimer?.cancel();
    _promoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      bottomNavigationBar: const Navbar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
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
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, Budi Sigma',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            'Selamat datang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none,
                          color: Color(0xFF124170)),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined,
                          color: Color(0xFF124170)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // SEARCH BAR
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari barang yang anda inginkan',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Color(0xFF124170)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // KATEGORI (dengan perbaikan spacing)
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
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16), // 🔹 diperlebar dari 12 ke 16

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    runSpacing: 20, // 🔹 sebelumnya 16
                    spacing: 20,    // 🔹 sebelumnya 16
                    children: [
                      _buildCategoryCircle(Icons.directions_walk, 'Trail'),
                      _buildCategoryCircle(Icons.remove_red_eye, 'Kacamata'),
                      _buildCategoryCircle(Icons.shopping_bag_outlined, 'Busana'),
                      _buildCategoryCircle(Icons.phone_android, 'Elektronik'),
                      _buildCategoryCircle(Icons.home_outlined, 'Dekorasi'),
                      _buildCategoryCircle(Icons.kitchen, 'Perabot'),
                    ],
                  ),
                ),

                const SizedBox(height: 30), // 🔹 sebelumnya 24

                // PROMO CAROUSEL (diperbaiki agar tidak dempet kiri)
                SizedBox(
                  height: 140,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: PageView(
                      controller: _promoController,
                      onPageChanged: (index) {
                        setState(() => currentPromo = index);
                      },
                      children: [
                        _buildPromoCard(
                          'assets/images/sepatu.png',
                          'Diskon Spesial 50%',
                          'Dapatkan promo sepatu lokal terbaik minggu ini!',
                        ),
                        _buildPromoCard(
                          'assets/images/Gelang_rajut.png',
                          'Promo Aksesoris 30%',
                          'Koleksi baru gelang rajut dengan harga hemat!',
                        ),
                        _buildPromoCard(
                          'assets/images/Jersey.png',
                          'Diskon Fashion 40%',
                          'Tampil sporty dan stylish dengan produk lokal!',
                        ),
                      ],
                    ),
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
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: productList.length,
                  itemBuilder: (context, index) {
                    final product = productList[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailProduct(product: product),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.asset(
                                product.imagePath,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10),
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
                                      color: Colors.black87,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp ${_formatPrice(product.price)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF124170),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        cart.addToCart(product);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF124170)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 8),
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

  Widget _buildCategoryCircle(IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kategori $label ditekan')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFF124170),
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black87,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard(String imagePath, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3A6188).withOpacity(0.25),
            const Color(0xFF6F7A74).withOpacity(0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.horizontal(left: Radius.circular(12)),
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
                      color: Color(0xFF124170),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
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
  }

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


test 123