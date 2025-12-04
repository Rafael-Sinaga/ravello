// lib/pages/search_result_page.dart
import 'package:flutter/material.dart';

import '../models/product_model.dart';
import 'detail_product.dart';

class SearchResultPage extends StatelessWidget {
  final String query;
  final List<Product> allProducts;

  const SearchResultPage({
    super.key,
    required this.query,
    required this.allProducts,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.toLowerCase();
    final List<Product> results = allProducts.where((product) {
      final name = product.name.toLowerCase();
      return name.contains(normalizedQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF124170)),
        title: Text(
          'Hasil untuk "$query"',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF124170),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF3F5FB),
      body: results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Tidak ada produk yang cocok dengan "$query".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Color(0xFF7B8794),
                  ),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final product = results[index];
                final hasDiscount =
                    product.discount != null && product.discount! > 0;
                final num discountedPrice = hasDiscount
                    ? product.price -
                        (product.price * (product.discount! / 100))
                    : product.price;

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailProduct(product: product),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product.imagePath.toString().startsWith('http')
                              ? Image.network(
                                  product.imagePath,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                )
                              : Image.asset(
                                  product.imagePath,
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF102A43),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (hasDiscount) ...[
                                Row(
                                  children: [
                                    Text(
                                      'Rp ${_formatPrice(product.price)}',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '-${product.discount!.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Colors.red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                'Rp ${_formatPrice(discountedPrice)}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF124170),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatPrice(num price) {
    final int value = price.round();
    final s = value.toString();
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
