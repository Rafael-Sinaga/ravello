// lib/pages/manage_products_page.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  bool _isLoading = false;
  String? _errorMessage;
  final List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadMyProducts();
  }

  // ================= LOAD PRODUK SELLER =================
  Future<void> _loadMyProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('storeId');

      if (storeId == null) {
        throw Exception('Store ID tidak ditemukan');
      }

      // 🔥 Ambil SEMUA produk (sudah terbukti jalan)
      final allProducts = await ProductService.fetchProducts();

      // 🔥 Filter produk milik seller ini
      final myProducts = allProducts.where((p) {
        if (p.storeId == null) return false;
        return p.storeId == storeId;
      }).toList();

      if (!mounted) return;
      setState(() {
        _products
          ..clear()
          ..addAll(myProducts);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Gagal memuat produk. Pastikan akun sudah terdaftar sebagai penjual.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        title: const Text(
          'Kelola Produk',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'Pastikan informasi produk lengkap agar pembeli lebih percaya.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          Expanded(child: _buildContent()),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _openAddProductSheet,
            icon: const Icon(Icons.add),
            label: const Text(
              'Tambah Produk Baru',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadMyProducts,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _buildProductCard(_products[i]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'Belum ada produk',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            'Tambahkan produk pertamamu untuk mulai berjualan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product p) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildImage(p.imagePath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${p.price.toStringAsFixed(0)} • Stok ${p.stock}',
                  style:
                      const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return const Icon(Icons.image_not_supported, size: 48);
    }
    if (kIsWeb || path.startsWith('http')) {
      return Image.network(path, width: 48, height: 48, fit: BoxFit.cover);
    }
    return Image.file(File(path), width: 48, height: 48, fit: BoxFit.cover);
  }

  // ================= ADD PRODUCT =================
  void _openAddProductSheet() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final descController = TextEditingController();
    XFile? pickedImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            InputDecoration inputDec(String label, String hint) {
              return InputDecoration(
                labelText: label,
                hintText: hint,
                filled: true,
                fillColor: const Color(0xFFF8FBFD),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Tambah Produk',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (img != null) {
                          setModalState(() => pickedImage = img);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade300),
                          color: const Color(0xFFF8FBFD),
                        ),
                        child: pickedImage == null
                            ? const Center(
                                child: Text(
                                  'Tambah Foto Produk',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: kIsWeb
                                    ? Image.network(pickedImage!.path,
                                        fit: BoxFit.cover)
                                    : Image.file(
                                        File(pickedImage!.path),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration:
                          inputDec('Nama Produk', 'Contoh: Kopi Arabika'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: inputDec('Harga', 'Contoh: 25000'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: inputDec('Stok', 'Contoh: 10'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration:
                          inputDec('Deskripsi', 'Ceritakan produkmu'),
                    ),

                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (pickedImage == null) return;

                        await ProductService.createProduct(
                          name: nameController.text.trim(),
                          description: descController.text.trim(),
                          price:
                              double.tryParse(priceController.text) ?? 0,
                          stock:
                              int.tryParse(stockController.text) ?? 0,
                          categoryId: 6,
                          imageFile: pickedImage,
                        );

                        if (!mounted) return;
                        Navigator.pop(context);
                        await _loadMyProducts();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Simpan Produk'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
