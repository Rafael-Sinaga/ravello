// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap; // optional untuk buka detail
  final double? width;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return SizedBox(
      width: width ?? 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // gambar
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.imagePath.isNotEmpty
                      ? (product.imagePath.startsWith('http')
                          ? Image.network(
                              product.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            )
                          : Image.asset(
                              product.imagePath,
                              fit: BoxFit.cover,
                            ))
                      : const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
              const SizedBox(height: 10),

              // harga
              Text(
                'Rp ${_formatPrice(product.price)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF124170),
                ),
              ),
              const SizedBox(height: 8),

              // tombol tambah
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFF124170)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_shopping_cart, color: Color(0xFF124170)),
                  label: const Text(
                    'Tambah',
                    style: TextStyle(
                      color: Color(0xFF124170),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () async {
                    // SELALU buka bottomsheet untuk pilih ukuran
                    final selected = await showModalBottomSheet<String?>(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (ctx) {
                        String? picked;

                        // fallback: kalau sizes kosong/null, pakai S M L XL
                        final sizes =
                            (product.sizes != null && product.sizes!.isNotEmpty)
                                ? product.sizes!
                                : const ['S', 'M', 'L', 'XL'];

                        return StatefulBuilder(
                          builder: (ctx2, setModalState) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                                bottom: MediaQuery.of(ctx2).viewInsets.bottom + 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Pilih Ukuran',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF124170),
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // ukuran bulat ala Figma (selalu ada)
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    children: sizes.map((s) {
                                      final isSelected = picked == s;
                                      return GestureDetector(
                                        onTap: () {
                                          setModalState(() {
                                            picked = s;
                                          });
                                        },
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
                                            s,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF1F2933),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),

                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => Navigator.pop(ctx, null),
                                          child: const Text('Batal'),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: picked == null
                                              ? null
                                              : () {
                                                  Navigator.pop(ctx, picked);
                                                },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF124170),
                                          ),
                                          child: const Text('Tambah'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );

                    // wajib pilih ukuran
                    if (selected == null) return;

                    final ok = cart.addToCart(product, size: selected);
                    if (ok) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} ($selected) ditambahkan ke keranjang',
                          ),
                          backgroundColor: const Color(0xFF124170),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Gagal menambahkan ke keranjang. Periksa pilihan ukuran.',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
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
