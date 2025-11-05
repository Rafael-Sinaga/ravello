// lib/pages/favorite_page.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  bool isEditing = false;
  final Set<int> selectedIndexes = {};

  // Dummy initial favorites - PASTIKAN price bertipe int
  final List<Product> favoriteProducts = [
    Product(
      name: 'Gelang Rajut',
      price: 300000000, // int
      imagePath: 'assets/images/Gelang_rajut.png',
      description: 'Gelang rajut handmade dengan bahan berkualitas tinggi.',
      discount: 10,
    ),
    Product(
      name: 'Rolex KW',
      price: 300000000, // int
      imagePath: 'assets/images/Rolex_KW.png',
      description: 'Jam tangan replika tampak elegan.',
      discount: 10,
    ),
    Product(
      name: 'FC Barcelona Home 08/09',
      price: 300000000, // int
      imagePath: 'assets/images/Jersey.png',
      description: 'Jersey klasik FC Barcelona musim 08/09.',
      discount: 10,
    ),
    Product(
      name: 'Adidas Ultra',
      price: 300000000, // int
      imagePath: 'assets/images/Sepatu.png',
      description: 'Sepatu olahraga nyaman untuk aktivitas harian.',
      discount: 10,
    ),
  ];

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) selectedIndexes.clear();
    });
  }

  void _toggleSelect(int index) {
    setState(() {
      if (selectedIndexes.contains(index)) {
        selectedIndexes.remove(index);
      } else {
        selectedIndexes.add(index);
      }
    });
  }

  void _removeSelected() {
    if (selectedIndexes.isEmpty) return;
    final deletedCount = selectedIndexes.length;

    final indexes = selectedIndexes.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final i in indexes) {
        if (i >= 0 && i < favoriteProducts.length) {
          favoriteProducts.removeAt(i);
        }
      }
      selectedIndexes.clear();
      isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$deletedCount produk dihapus dari favorit'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // PERBAIKAN: Function yang handle double dan int
  String _formatCurrency(dynamic price) {
    // Convert ke int terlebih dahulu
    final intValue = (price is int) ? price : (price as double).toInt();
    
    return 'Rp. ${intValue.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Favorit Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _toggleEditMode,
              child: Text(
                isEditing ? 'Selesai' : 'Edit',
                style: const TextStyle(
                  color: Color(0xFF124170),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: favoriteProducts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Tidak ada produk favorit.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: favoriteProducts.length,
                    itemBuilder: (context, index) {
                      final product = favoriteProducts[index];
                      final isSelected = selectedIndexes.contains(index);

                      return Column(
                        children: [
                          _favoriteItem(product, index, isSelected),
                          if (index < favoriteProducts.length - 1)
                            const Divider(
                              height: 32,
                              thickness: 1,
                              color: Color(0xFFE5E5E5),
                            ),
                        ],
                      );
                    },
                  ),
          ),

          // Tombol hapus (selalu visible ketika ada produk)
          if (favoriteProducts.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: ElevatedButton(
                onPressed: isEditing && selectedIndexes.isNotEmpty
                    ? _removeSelected
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF124170),
                  disabledBackgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  isEditing
                      ? selectedIndexes.isEmpty
                          ? 'Hapus Favorit'
                          : 'Hapus (${selectedIndexes.length})'
                      : 'Hapus Favorit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _favoriteItem(Product product, int index, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF124170).withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox untuk mode edit
          if (isEditing)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 12),
              child: GestureDetector(
                onTap: () => _toggleSelect(index),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF124170) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF124170)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
            ),

          // Gambar produk
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                product.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey.shade200,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image, color: Colors.grey, size: 32),
                ),
              ),
            ),
          ),

          // Info produk
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge diskon
                  if (product.discount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.discount}% off',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (product.discount != null) const SizedBox(height: 8),

                  // Nama produk
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Harga - PERBAIKAN: Tidak ada error type
                  Text(
                    _formatCurrency(product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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
}