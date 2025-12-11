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
  int currentImageIndex = 0;

  bool _isFavorited = false;
  late String _favKey;

  bool _isBoosted = false;

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
    _checkBoostStatus();

    // preselect size if product.sizes has exactly one value
    final resolvedSizes = _resolveSizes();
    if (resolvedSizes != null && resolvedSizes.length == 1) {
      selectedSize = resolvedSizes.first;
    }
  }

  Future<void> _checkBoostStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('boosted_product_ids') ?? <String>[];
    final ids = list.map((e) => int.tryParse(e)).whereType<int>().toSet();

    final id = widget.product.productId;
    if (id != null) {
      final idInt = int.tryParse(id.toString());
      if (idInt != null && ids.contains(idInt)) {
        if (mounted) {
          setState(() => _isBoosted = true);
        } else {
          _isBoosted = true;
        }
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
          SnackBar(
            content: Text(
              '${widget.product.name.isNotEmpty ? widget.product.name : 'Produk'} dihapus dari favorit',
            ),
          ),
        );
      } else {
        favs.add(_favKey);
        _isFavorited = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product.name.isNotEmpty ? widget.product.name : 'Produk'} ditambahkan ke favorit',
            ),
          ),
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
    if (name == null || name.trim().isEmpty) return 'Toko tidak diketahui';
    return name;
  }

  /// Resolve sizes: prefer product.sizes (already parsed by model).
  /// If null/empty try to extract from description heuristically.
  List<String>? _resolveSizes() {
    final sizes = widget.product.sizes;
    if (sizes != null && sizes.isNotEmpty) return sizes;

    final fromDesc =
        _extractSizesFromDescription(widget.product.description);
    if (fromDesc != null && fromDesc.isNotEmpty) return fromDesc;

    return null;
  }

  /// Heuristic parser: cari pola "Ukuran: ...", "Size: ...", atau array di deskripsi.
  List<String>? _extractSizesFromDescription(String? desc) {
    if (desc == null || desc.trim().isEmpty) return null;
    final text = desc.trim();

    // 1) cari isi di dalam kurung siku: [S, M, L] atau ["S","M","L"]
    final bracketMatch = RegExp(r'\[([^\]]+)\]').firstMatch(text);
    if (bracketMatch != null) {
      final inside = bracketMatch.group(1); // isi di dalam [...]
      if (inside != null && inside.trim().isNotEmpty) {
        final parsed = _splitSizesString(inside);
        if (parsed.isNotEmpty) return parsed;
      }
    }

    // 2) cari label "Ukuran" atau "Size" dan ambil sisa baris setelahnya
    final labelRegex = RegExp(
      r'(?:(?:ukuran|size)\s*[:\-]\s*)([^\n\r]+)',
      caseSensitive: false,
    );
    final labelMatch = labelRegex.firstMatch(text);
    if (labelMatch != null) {
      final capture = labelMatch.group(1);
      if (capture != null && capture.trim().isNotEmpty) {
        final parsed = _splitSizesString(capture);
        if (parsed.isNotEmpty) return parsed;
      }
    }

    // 3) cari pola "Ukuran" di baris baru seperti "Ukuran\nS M L"
    final blockLabelRegex = RegExp(
      r'(?:(?:ukuran|size)\s*[\r\n]+)([^\n\r]+)',
      caseSensitive: false,
    );
    final blockMatch = blockLabelRegex.firstMatch(text);
    if (blockMatch != null) {
      final capture = blockMatch.group(1);
      if (capture != null && capture.trim().isNotEmpty) {
        final parsed = _splitSizesString(capture);
        if (parsed.isNotEmpty) return parsed;
      }
    }

    // 4) fallback: cari token yang looks like sizes (S, M, L, XL, XXL, 36,38)
    final tokens = text
        .split(RegExp(r'[\s,;|·•\n\r]+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final common = <String>{
      'xs',
      's',
      'm',
      'l',
      'xl',
      'xxl',
      'xxxl',
      '36',
      '37',
      '38',
      '39',
      '40',
      '41',
      '42',
      '43',
      '44',
      '45'
    };
    final found = <String>[];
    for (final t in tokens) {
      final low = t.toLowerCase();
      if (common.contains(low) && !found.contains(t)) {
        found.add(t);
      }
      // allow things like "S/M/L" or "S-M-L"
      if (t.contains('/') || t.contains('-')) {
        final parts = t
            .split(RegExp(r'[\/\-]'))
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();
        for (final p in parts) {
          if (!found.contains(p)) found.add(p);
        }
      }
    }
    return found.isEmpty ? null : found;
  }

  List<String> _splitSizesString(String raw) {
    final cleaned = raw.replaceAll('"', '').replaceAll("'", '').trim();
    final normalized = cleaned
        .replaceAll('|', ',')
        .replaceAll(';', ',')
        .replaceAll('/', ',');
    final parts = normalized
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    // If no comma-based split, maybe space separated
    if (parts.length <= 1) {
      final bySpace = cleaned
          .split(RegExp(r'\s+'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (bySpace.length > 1) return bySpace;
    }
    return parts;
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount =
        widget.product.discount != null && widget.product.discount! > 0;
    final discountedPrice = hasDiscount
        ? widget.product.price -
            (widget.product.price * (widget.product.discount! / 100))
        : widget.product.price;

    // safe fallbacks for name/description
    final productName = widget.product.name.isNotEmpty
        ? widget.product.name
        : 'Produk tanpa nama';
    final productDescription =
        widget.product.description.isNotEmpty
            ? widget.product.description
            : 'Deskripsi tidak tersedia untuk produk ini.';

    // imagePath fallback
    final imagePath = widget.product.imagePath;
    final bool hasImage = imagePath.isNotEmpty;

    // hero tag: prefer imagePath (unique), else productId, else name fallback
    final heroTag =
        hasImage ? imagePath : (widget.product.productId?.toString() ?? productName);

    // kalau dari backend / deskripsi tidak ketemu ukuran,
    // fallback ke S M L XL supaya user tetap bisa pilih
    final List<String> resolvedSizes =
        _resolveSizes() ?? const ['S', 'M', 'L', 'XL'];

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
          productName,
          style: const TextStyle(
            color: Color(0xFF124170),
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFE7F1FA)],
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
                        horizontal: 14,
                        vertical: 16,
                      ),
                      child: Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: hasImage
                              ? (imagePath.startsWith('http')
                                  ? Image.network(
                                      imagePath,
                                      height: 200,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(
                                        Icons.broken_image,
                                        size: 80,
                                      ),
                                    )
                                  : (kIsWeb
                                      ? Image.network(
                                          imagePath,
                                          height: 200,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                            Icons.broken_image,
                                            size: 80,
                                          ),
                                        )
                                      : (File(imagePath).existsSync()
                                          ? Image.file(
                                              File(imagePath),
                                              height: 200,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                size: 80,
                                              ),
                                            )
                                          : Image.asset(
                                              imagePath,
                                              height: 200,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                size: 80,
                                              ),
                                            ))))
                              : Container(
                                  height: 200,
                                  width: 200,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.image_not_supported_rounded,
                                    size: 80,
                                    color: Color(0xFF9CA3AF),
                                  ),
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
                            horizontal: 8,
                            vertical: 4,
                          ),
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

              Text(
                productName,
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
                        vertical: 2,
                        horizontal: 6,
                      ),
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

              // UKURAN + FAVORITE
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
                      color:
                          _isFavorited ? Colors.red : const Color(0xFF124170),
                      size: 28,
                    ),
                    onPressed: _toggleFavorite,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ukuran dalam bentuk bulat (S, M, L, XL)
              Wrap(
                spacing: 10,
                children: resolvedSizes.map((size) {
                  final isSelected = selectedSize == size;
                  return GestureDetector(
                    onTap: () => setState(() => selectedSize = size),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? const Color(0xFF124170)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF124170)
                              : const Color(0xFFCBD5E1),
                          width: 1.4,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        size,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF1F2933),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

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
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.18),
                  ),
                ),
                child: Text(
                  productDescription,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.5,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              const SizedBox(height: 20),

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
                    colors: [Color(0xFFE5EDFF), Color(0xFFF5F7FF)],
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

              // ULASAN
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
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.18),
                  ),
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
                          horizontal: 10,
                          vertical: 8,
                        ),
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
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    const Color(0xFFE5EDFF),
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

      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final sizes = resolvedSizes;
                  if (sizes.isNotEmpty &&
                      (selectedSize == null || selectedSize!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih ukuran terlebih dahulu!'),
                      ),
                    );
                    return;
                  }

                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(
                    widget.product,
                    size: selectedSize,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${widget.product.name.isNotEmpty ? widget.product.name : 'Produk'}${selectedSize != null ? ' (${selectedSize!})' : ''} ditambahkan ke keranjang',
                      ),
                      backgroundColor: const Color(0xFF124170),
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
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  final sizes = resolvedSizes;
                  if (sizes.isNotEmpty &&
                      (selectedSize == null || selectedSize!.isEmpty)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pilih ukuran terlebih dahulu!'),
                      ),
                    );
                    return;
                  }

                  Provider.of<CartProvider>(context, listen: false)
                      .addToCart(
                    widget.product,
                    size: selectedSize,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckoutPage(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF124170)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF124170),
          ),
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
          Icon(
            icon,
            size: 13,
            color: const Color(0xFF124170),
          ),
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
        }
        if (index == fullStars && hasHalf) {
          return const Icon(
            Icons.star_half_rounded,
            size: 14,
            color: starColor,
          );
        }
        return const Icon(
          Icons.star_border_rounded,
          size: 14,
          color: starColor,
        );
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
                    onChanged: (val) =>
                        setModalState(() => tempRating = val),
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
                      hintText:
                          'Ceritakan pengalamanmu dengan produk ini...',
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
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Ulasan tidak boleh kosong.'),
                                ),
                              );
                              return;
                            }
                            final prefs =
                                await SharedPreferences.getInstance();
                            final name =
                                prefs.getString('current_user_name') ??
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

                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Terima kasih! Ulasan kamu telah ditambahkan.',
                                ),
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
