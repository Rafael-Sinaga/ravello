import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';
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

  @override
  void initState() {
    super.initState();

    // identifier unik
    _favKey =
        '${widget.product.name}_${widget.product.price}_${widget.product.imagePath}';

    _loadFavorite();
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
              Center(
                child: Hero(
                  tag: widget.product.imagePath,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.product.imagePath,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ===================
              // NAMA & HARGA
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

              if (hasDiscount)
                Row(
                  children: [
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
                ),

              const SizedBox(height: 4),

              Text(
                'Rp ${_formatPrice(discountedPrice)}',
                style: const TextStyle(
                  color: Color(0xFF124170),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
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
                      color: _isFavorited ? Colors.red : Color(0xFF124170),
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
                        color:
                            isSelected ? const Color(0xFF124170) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF124170)
                              : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(8),
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

              const SizedBox(height: 20),

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

              Text(
                widget.product.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                  fontFamily: 'Poppins',
                ),
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
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
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
