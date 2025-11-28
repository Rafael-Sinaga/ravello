// lib/pages/manage_products_page.dart
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
            child: _products.isEmpty
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
                : ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return _buildProductCard(product, index);
                    },
                  ),
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

      if (kIsWeb) {
        // Flutter Web → pakai network
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            product.imagePath!,
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Mobile / desktop → pakai File
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(product.imagePath!),
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
              setState(() {
                _products.removeAt(index);
              });
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
    );
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
                                content:
                                    Text('Nama, harga, dan stok wajib diisi.'),
                              ),
                            );
                            return;
                          }

                          final price = double.tryParse(priceText) ?? 0;
                          final stock = int.tryParse(stockText) ?? 0;

                          if (editing && product != null && index != null) {
                            setState(() {
                              _products[index] = _ProductItem(
                                name: name,
                                price: price,
                                stock: stock,
                                description: desc,
                                imagePath: pickedImage?.path,
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
                            final result = await ProductService.createProduct(
                              name: name,
                              description: desc,
                              price: price,
                              stock: stock,
                              categoryId: 1,
                            );

                            if (!mounted) return;

                            if (result['success'] == true) {
                              setState(() {
                                _products.add(
                                  _ProductItem(
                                    name: name,
                                    price: price,
                                    stock: stock,
                                    description: desc,
                                    imagePath: pickedImage?.path,
                                  ),
                                );
                              });

                              // PERBAIKAN:
                              // Baris lama disimpan sebagai komentar:
                              // Navigator.pop(context);
                              //
                              // Baris baru mengirim "true" ke halaman pemanggil
                              // supaya bisa refresh data / HomePage.
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.2,
        ),
      ),
    );
  }
}

// ================== MODEL SEDERHANA UNTUK HALAMAN INI SAJA ==================

class _ProductItem {
  final String name;
  final double price;
  final int stock;
  final String description;
  final String? imagePath;

  _ProductItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    this.imagePath,
  });
}
