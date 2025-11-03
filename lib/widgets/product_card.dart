// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../pages/detail_product.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount != null && product.discount! > 0;
    final discountedPrice = hasDiscount
        ? product.price - (product.price * product.discount! / 100)
        : product.price;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailProduct(product: product),
          ),
        );
      },
      child: Container(
        width: 140,
        height: 190,
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF124170).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Stack(
              alignment: Alignment.topRight,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      product.imagePath,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                        height: 70,
                        width: 70,
                        child: Icon(Icons.broken_image,
                            size: 36, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 0,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        '${product.discount!.toStringAsFixed(0)}% off',
                        style: const TextStyle(
                          fontSize: 9,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 6),

            // Nama produk
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Harga
            Padding(
              padding: const EdgeInsets.only(top: 1, bottom: 3),
              child: Text(
                'Rp ${discountedPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF124170),
                ),
              ),
            ),

            // Tombol Tambah
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 25),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  side: const BorderSide(color: Color(0xFF124170)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.shopping_bag_outlined,
                    size: 13, color: Color(0xFF124170)),
                label: const Text(
                  'Tambah',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Color(0xFF124170),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
