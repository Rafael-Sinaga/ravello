import 'package:flutter/material.dart';

class ManageProductsPage extends StatefulWidget {
  const ManageProductsPage({super.key});

  @override
  State<ManageProductsPage> createState() => _ManageProductsPageState();
}

class _ManageProductsPageState extends State<ManageProductsPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  final List<_ProductItem> _products = [
    _ProductItem(
      name: 'Serum Wajah Organik',
      price: 75000,
      stock: 12,
      description: 'Serum wajah dengan bahan alami untuk kulit cerah dan lembap.',
    ),
    _ProductItem(
      name: 'Face Wash Tea Tree',
      price: 52000,
      stock: 20,
      description: 'Pembersih wajah untuk kulit berminyak dan berjerawat.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: primaryColor),
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
          child: const Icon(
            Icons.image_outlined,
            color: primaryColor,
          ),
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
              _openAddProductSheet(editing: true, product: product, index: index);
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
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
                  onTap: () {
                    // TODO: sambungkan ke ImagePicker / upload gambar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur upload gambar belum dihubungkan.'),
                      ),
                    );
                  },
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
                      children: const [
                        Icon(
                          Icons.cloud_upload_outlined,
                          color: primaryColor,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Upload Foto Produk',
                          style: TextStyle(
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
                  decoration: _inputDecoration('Tuliskan deskripsi produk'),
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
                    onPressed: () {
                      final name = nameController.text.trim();
                      final priceText = priceController.text.trim();
                      final stockText = stockController.text.trim();

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
                            description: descController.text.trim(),
                          );
                        });
                      } else {
                        setState(() {
                          _products.add(
                            _ProductItem(
                              name: name,
                              price: price,
                              stock: stock,
                              description: descController.text.trim(),
                            ),
                          );
                        });
                      }

                      Navigator.pop(context);
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

  _ProductItem({
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
  });
}
