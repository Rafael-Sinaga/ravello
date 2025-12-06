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

  // list produk (awal kosong, tidak ada dummy)
  final List<_ProductItem> _products = [];

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyProducts();
  }

  Future<void> _loadMyProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storeId = prefs.getInt('storeId');

      // 🔥 Ambil daftar produk yang sedang di-boost dari SharedPreferences
      final boostedList = prefs.getStringList('boosted_product_ids') ?? <String>[];
      final boostedIds = boostedList
          .map((e) => int.tryParse(e))
          .whereType<int>()
          .toSet();

      // Ambil semua produk dari backend
      final allProducts = await ProductService.fetchProducts();

      // Filter produk yang punya storeId sama dengan toko ini
      final myProducts = storeId == null
          ? allProducts
          : allProducts.where((p) => p.storeId == storeId).toList();

      setState(() {
        _products
          ..clear()
          ..addAll(
            myProducts.map(
              (p) => _ProductItem.fromProduct(
                p,
                isBoosted: p.productId != null &&
                    boostedIds.contains(p.productId),
              ),
            ),
          );
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat produk: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔥 Toggle status boost untuk satu produk
  Future<void> _toggleBoost(_ProductItem product) async {
    if (product.productId == null) {
      // Produk belum punya ID backend → nanti kalau sudah tersimpan bisa di-boost
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Produk belum memiliki ID dari server, boost akan aktif setelah produk tersimpan.',
          ),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final List<String> boostedList =
        prefs.getStringList('boosted_product_ids') ?? <String>[];

    final idStr = product.productId.toString();
    bool newStatus;

    if (boostedList.contains(idStr)) {
      // matikan boost
      boostedList.remove(idStr);
      newStatus = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${product.name}" tidak di-boost lagi.',
          ),
        ),
      );
    } else {
      // aktifkan boost
      boostedList.add(idStr);
      newStatus = true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '"${product.name}" sedang di-boost dan akan tampil lebih menonjol.',
          ),
        ),
      );
    }

    await prefs.setStringList('boosted_product_ids', boostedList);

    // update state lokal
    if (!mounted) return;
    setState(() {
      final index = _products.indexWhere(
        (p) => p.productId == product.productId,
      );
      if (index != -1) {
        _products[index] = _products[index].copyWith(isBoosted: newStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kelola Produk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ====== HEADER / INFO SINGKAT ======
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: backgroundColor,
            child: const Text(
              'Tambah dan kelola produk yang dijual di toko kamu.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6F7A74),
              ),
            ),
          ),

          // ====== LIST PRODUK ======
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24.0, vertical: 8),
                          child: Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6F7A74),
                            ),
                          ),
                        ),
                      )
                    : _products.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada produk.\nTambahkan produk pertama kamu.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6F7A74),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMyProducts,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              itemCount: _products.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return _buildProductCard(product, index);
                              },
                            ),
                          )),
          ),

          // ====== TOMBOL TAMBAH PRODUK ======
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _openAddProductSheet,
                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Tambah Produk',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================== KARTU PRODUK ==================

  Widget _buildProductCard(_ProductItem product, int index) {
    Widget _buildThumb() {
      if (product.imagePath == null) {
        return const Icon(
          Icons.image_outlined,
          color: primaryColor,
        );
      }

      final path = product.imagePath!;
      final isNetworkImage =
          path.startsWith('http://') || path.startsWith('https://');

      if (kIsWeb || isNetworkImage) {
        // Flutter Web atau URL gambar dari backend
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            path,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Mobile / desktop dengan path lokal (File)
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(path),
            fit: BoxFit.cover,
          ),
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // ListTile utama (produk)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 6, bottom: 2),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3ECF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildThumb(),
              ),
              title: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Stok: ${product.stock}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6F7A74),
                    ),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _openAddProductSheet(
                      editing: true,
                      product: product,
                      index: index,
                    );
                  } else if (value == 'delete') {
                    _deleteProduct(product, index);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit produk'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus produk'),
                  ),
                ],
              ),
            ),
          ),

          // 🔥 Tombol Boost mengambang di pojok kanan atas
          Positioned(
            top: 6,
            right: 8,
            child: GestureDetector(
              onTap: () => _toggleBoost(product),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.isBoosted
                      ? const Color(0xFFFFF3E0)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: product.isBoosted
                        ? const Color(0xFFF97316)
                        : primaryColor.withOpacity(0.55),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 14,
                      color: product.isBoosted
                          ? const Color(0xFFEA580C)
                          : primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isBoosted ? 'Boost aktif' : 'Boost',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: product.isBoosted
                            ? const Color(0xFFEA580C)
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(_ProductItem product, int index) async {
    // Kalau belum punya productId (produk lokal aja), hapus dari list saja
    if (product.productId == null) {
      setState(() {
        _products.removeAt(index);
      });
      return;
    }

    final res = await ProductService.deleteProduct(product.productId!);

    if (!mounted) return;

    if (res['success'] == true) {
      setState(() {
        _products.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'Produk berhasil dihapus.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res['message'] ?? 'Gagal menghapus produk dari server.',
          ),
        ),
      );
    }
  }

  // ================== BOTTOM SHEET: FORM PRODUK ==================

  void _openAddProductSheet({
    bool editing = false,
    _ProductItem? product,
    int? index,
  }) {
    final nameController =
        TextEditingController(text: editing ? product?.name : '');
    final priceController =
        TextEditingController(text: editing ? product?.price.toString() : '');
    final stockController =
        TextEditingController(text: editing ? product?.stock.toString() : '');
    final descController =
        TextEditingController(text: editing ? product?.description : '');
    XFile? pickedImage = editing && product?.imagePath != null
        ? XFile(product!.imagePath!)
        : null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> _pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? img = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (img != null) {
                setModalState(() {
                  pickedImage = img;
                });
              }
            }

            Widget _buildPreview() {
              if (pickedImage == null) {
                return const Icon(
                  Icons.cloud_upload_outlined,
                  color: primaryColor,
                );
              }

              if (kIsWeb) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    pickedImage!.path,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(pickedImage!.path),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                );
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Text(
                      editing ? 'Edit Produk' : 'Tambah Produk',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Upload gambar
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            _buildPreview(),
                            const SizedBox(width: 10),
                            Text(
                              pickedImage != null
                                  ? 'Ubah Foto Produk'
                                  : 'Upload Foto Produk',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6F7A74),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Nama produk
                    const Text(
                      'Nama Produk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: _inputDecoration('Masukkan nama produk'),
                    ),

                    const SizedBox(height: 12),

                    // Harga & stok (2 kolom)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Harga',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Rp'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stok',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('0'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Deskripsi
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration:
                          _inputDecoration('Tuliskan deskripsi produk'),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final priceText = priceController.text.trim();
                          final stockText = stockController.text.trim();
                          final desc = descController.text.trim();

                          if (name.isEmpty ||
                              priceText.isEmpty ||
                              stockText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Nama, harga, dan stok wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          final price = double.tryParse(priceText) ?? 0;
                          final stock = int.tryParse(stockText) ?? 0;

                          if (editing && product != null && index != null) {
                            // Kalau belum punya productId, edit lokal saja
                            if (product.productId == null) {
                              setState(() {
                                _products[index] = _ProductItem(
                                  productId: null,
                                  storeId: product.storeId,
                                  name: name,
                                  price: price,
                                  stock: stock,
                                  description: desc,
                                  imagePath:
                                      pickedImage?.path ?? product.imagePath,
                                  isBoosted: product.isBoosted,
                                );
                              });

                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Perubahan produk disimpan di aplikasi.'),
                                ),
                              );
                            } else {
                              final result =
                                  await ProductService.updateProduct(
                                productId: product.productId!,
                                name: name,
                                description: desc,
                                price: price,
                                stock: stock,
                                categoryId: 1,
                              );

                              if (!mounted) return;

                              if (result['success'] == true) {
                                setState(() {
                                  _products[index] = _ProductItem(
                                    productId: product.productId,
                                    storeId: product.storeId,
                                    name: name,
                                    price: price,
                                    stock: stock,
                                    description: desc,
                                    imagePath:
                                        pickedImage?.path ?? product.imagePath,
                                    isBoosted: product.isBoosted,
                                  );
                                });

                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ??
                                          'Perubahan produk berhasil disimpan.',
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result['message'] ??
                                          'Gagal menyimpan perubahan produk.',
                                    ),
                                  ),
                                );
                              }
                            }
                          } else {
                            final result =
                                await ProductService.createProduct(
                              name: name,
                              description: desc,
                              price: price,
                              stock: stock,
                              categoryId: 1,
                              // saat ini image belum dikirim ke backend
                            );

                            if (!mounted) return;

                            if (result['success'] == true) {
                              setState(() {
                                _products.add(
                                  _ProductItem(
                                    productId: result['product_id'] as int?,
                                    storeId: result['store_id'] as int?,
                                    name: name,
                                    price: price,
                                    stock: stock,
                                    description: desc,
                                    imagePath: pickedImage?.path,
                                    isBoosted: false,
                                  ),
                                );
                              });

                              Navigator.pop(context, true);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ??
                                        'Produk berhasil ditambahkan.',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result['message'] ??
                                        'Gagal menambahkan produk.',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          editing ? 'Simpan Perubahan' : 'Simpan Produk',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Color(0xFFB0BEC5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.grey.withOpacity(0.4),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
      ),
    );
  }
}

// ================== MODEL SEDERHANA UNTUK HALAMAN INI SAJA ==================

class _ProductItem {
  final int? productId;
  final int? storeId;
  final String name;
  final double price;
  final int stock;
  final String description;
  final String? imagePath;
  final bool isBoosted; // 🔥 flag boost lokal

  _ProductItem({
    this.productId,
    this.storeId,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    this.imagePath,
    this.isBoosted = false,
  });

  factory _ProductItem.fromProduct(Product p, {bool isBoosted = false}) {
    return _ProductItem(
      productId: p.productId,
      storeId: p.storeId,
      name: p.name,
      price: p.price.toDouble(),
      stock: p.stock,
      description: p.description,
      imagePath: p.imagePath,
      isBoosted: isBoosted,
    );
  }

  _ProductItem copyWith({
    int? productId,
    int? storeId,
    String? name,
    double? price,
    int? stock,
    String? description,
    String? imagePath,
    bool? isBoosted,
  }) {
    return _ProductItem(
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      isBoosted: isBoosted ?? this.isBoosted,
    );
  }
}
