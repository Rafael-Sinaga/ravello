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
  int currentImageIndex = 0;

  bool _isFavorited = false;
  late String _favKey;

  bool _isBoosted = false; // <<=== status boosted untuk produk ini

  // ====== STATE ULASAN (LOKAL) ======
  final List<_Review> _reviews = [
    _Review(
      userName: 'Rafael',
      rating: 4.5,
      comment:
          'Kualitas bahan bagus, jahitan rapi. Dipakai nonton bola nyaman banget, nggak gerah.',
      dateLabel: '2 hari lalu',
    ),
    _Review(
      userName: 'Grace',
      rating: 5.0,
      comment:
          'Warnanya sesuai foto, packing rapi, pengiriman juga cepat. Recommended seller!',
      dateLabel: '5 hari lalu',
    ),
    _Review(
      userName: 'Andi',
      rating: 4.0,
      comment:
          'Overall oke, cuma sedikit longgar di bagian bahu. Tapi masih aman dipakai harian.',
      dateLabel: '1 minggu lalu',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _favKey =
        '${widget.product.name}_${widget.product.price}_${widget.product.imagePath}';

    _loadFavorite();
    _checkBoostStatus(); // cek apakah produk ini termasuk boosted
  }

  Future<void> _checkBoostStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('boosted_product_ids') ?? <String>[];
    final ids = list.map((e) => int.tryParse(e)).whereType<int>().toSet();

    final id = widget.product.productId;
    if (id != null && ids.contains(id)) {
      if (mounted) {
        setState(() {
          _isBoosted = true;
        });
      } else {
        _isBoosted = true;
      }
    }
  }

  Future<void> _loadFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? <String>[];

    setState(() {
      _isFavorited = favs.contains(_favKey);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? <String>[];

    setState(() {
      if (_isFavorited) {
        favs.remove(_favKey);
        _isFavorited = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.name} dihapus dari favorit')),
        );
      } else {
        favs.add(_favKey);
        _isFavorited = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('${widget.product.name} ditambahkan ke favorit')),
        );
      }
    });

    await prefs.setStringList('favorites', favs);
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / _reviews.length;
  }

  String get _storeDisplayName {
    final name = widget.product.storeName;
    if (name == null || name.trim().isEmpty) {
      return 'Toko tidak diketahui';
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

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
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: Color(0xFF124170),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),

      // ===================
      // BODY
      // ===================
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===================
              // IMAGE CARD LEBIH WAH + BADGE BOOST
              // ===================
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFE7F1FA),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 16),
                      child: Hero(
                        tag: widget.product.imagePath,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: widget.product.imagePath.startsWith('http')
                              ? Image.network(
                                  widget.product.imagePath,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, size: 80),
                                )
                              : Image.asset(
                                  widget.product.imagePath,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                        ),
                      ),
                    ),

                    if (_isBoosted)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
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
                                size: 14,
                                color: Colors.deepOrange,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Produk Boosted',
                                style: TextStyle(
                                  fontSize: 11,
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
              ),

              const SizedBox(height: 18),

              // ===================
              // NAMA & HARGA + BADGE DISKON
              // ===================
              Text(
                widget.product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF124170),
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 4),

              Row(
                children: [
                  if (hasDiscount) ...[
                    Text(
                      'Rp ${_formatPrice(widget.product.price)}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${widget.product.discount!.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 4),

              Text(
                'Rp ${_formatPrice(discountedPrice)}',
                style: const TextStyle(
                  color: Color(0xFF124170),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 10),

              // Chip info singkat
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.local_shipping_outlined,
                    label: 'Pengiriman cepat',
                  ),
                  const SizedBox(width: 6),
                  _buildInfoChip(
                    icon: Icons.verified_outlined,
                    label: 'Produk original',
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ===================
              // UKURAN + FAVORITE BUTTON
              // ===================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Ukuran',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isFavorited
                          ? Icons.favorite
                          : Icons.favorite_border_outlined,
                      color: _isFavorited ? Colors.red : const Color(0xFF124170),
                      size: 28,
                    ),
                    onPressed: _toggleFavorite,
                  )
                ],
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: ['S', 'M', 'L', 'XL'].map((size) {
                  final isSelected = selectedSize == size;

                  return GestureDetector(
                    onTap: () => setState(() => selectedSize = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF124170)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF124170)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF124170).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        size,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ===================
              // DESKRIPSI
              // ===================
              const Text(
                'Deskripsi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 6),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  widget.product.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===================
              // INFORMASI TOKO
              // ===================
              const Text(
                'Toko',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFE5EDFF),
                      Color(0xFFF5F7FF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF124170).withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF124170).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFF124170),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _storeDisplayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 14,
                                    color: Color(0xFFFFB800),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _reviews.isEmpty
                                        ? 'Belum ada ulasan'
                                        : '${_averageRating.toStringAsFixed(1)} • ${_reviews.length} ulasan',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6B7280),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Penjual di platform ini',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: Color(0xFF9CA3AF),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStoreTag(
                          icon: Icons.verified_rounded,
                          label: 'Toko aktif',
                        ),
                        const SizedBox(width: 6),
                        _buildStoreTag(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Respon cepat',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===================
              // ULASAN PEMBELI
              // ===================
              const Text(
                'Ulasan Pembeli',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 6),

              // Ringkasan rating
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.18)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDFF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFB800),
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _reviews.isEmpty
                          ? const Text(
                              'Belum ada ulasan. Jadilah yang pertama menulis ulasan untuk produk ini.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontFamily: 'Poppins',
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _averageRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 18,
                                      color: Color(0xFFFFB800),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_reviews.length} ulasan',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _openAddReviewSheet,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF124170)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text(
                        'Tulis Ulasan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF124170),
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              if (_reviews.isNotEmpty)
                ListView.separated(
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.grey.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFE5EDFF),
                                child: Text(
                                  review.userName.isNotEmpty
                                      ? review.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF124170),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userName,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        _buildStarRow(review.rating),
                                        const SizedBox(width: 4),
                                        Text(
                                          review.dateLabel,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF9CA3AF),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            review.comment,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              height: 1.4,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      // ===================
      // BOTTOM BUTTONS
      // ===================
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (selectedSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Pilih ukuran terlebih dahulu!')),
                    );
                    return;
                  }

                  cartProvider.addToCart(widget.product);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${widget.product.name} (${selectedSize!}) ditambahkan ke keranjang'),
                      backgroundColor: const Color(0xFF124170),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF124170),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Tambah ke Keranjang',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (selectedSize == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih ukuran terlebih dahulu!'),
                      ),
                    );
                    return;
                  }

                  cartProvider.addToCart(widget.product);

                  Navigator.pushNamed(context, '/checkout');
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF124170)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    color: Color(0xFF124170),
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====== HELPER UI & ULASAN ======

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF124170)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF124170),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF124170).withOpacity(0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF124170)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF124170),
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRow(double rating) {
    const Color starColor = Color(0xFFFFB800);
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return const Icon(
            Icons.star_rounded,
            size: 14,
            color: starColor,
          );
        } else if (index == fullStars && hasHalf) {
          return const Icon(
            Icons.star_half_rounded,
            size: 14,
            color: starColor,
          );
        } else {
          return const Icon(
            Icons.star_border_rounded,
            size: 14,
            color: starColor,
          );
        }
      }),
    );
  }

  void _openAddReviewSheet() async {
    final commentController = TextEditingController();
    double tempRating = 5;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Tulis Ulasan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF124170),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Berikan rating untuk produk ini:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStarRow(tempRating),
                      const SizedBox(width: 8),
                      Text(
                        tempRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempRating,
                    min: 1,
                    max: 5,
                    divisions: 8,
                    label: tempRating.toStringAsFixed(1),
                    activeColor: const Color(0xFF124170),
                    onChanged: (val) {
                      setModalState(() {
                        tempRating = val;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ulasan kamu:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ceritakan pengalamanmu dengan produk ini...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Batal',
                            style: TextStyle(fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final comment =
                                commentController.text.trim();

                            if (comment.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Ulasan tidak boleh kosong.'),
                                ),
                              );
                              return;
                            }

                            final prefs =
                                await SharedPreferences.getInstance();
                            final name = prefs
                                    .getString('current_user_name') ??
                                'Pengguna';

                            setState(() {
                              _reviews.insert(
                                0,
                                _Review(
                                  userName: name,
                                  rating: tempRating,
                                  comment: comment,
                                  dateLabel: 'Baru saja',
                                ),
                              );
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Terima kasih! Ulasan kamu telah ditambahkan.'),
                                backgroundColor: Color(0xFF124170),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF124170),
                          ),
                          child: const Text(
                            'Kirim',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
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

// ====== MODEL ULASAN LOKAL ======

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
