import 'package:flutter/material.dart';

class CheckoutItem extends StatelessWidget {
  final dynamic product; // dynamic supaya kompatibel

  const CheckoutItem({
    super.key,
    required this.product,
  });

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    final s = value.toString();
    final cleaned = s.replaceAll(RegExp(r'[^\d\.,]'), '').replaceAll(',', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String _imagePath(dynamic p) {
    try {
      final img = (p as dynamic).image;
      if (img != null && img.toString().isNotEmpty) return img.toString();
    } catch (_) {}
    try {
      final imgp = (p as dynamic).imagePath;
      if (imgp != null && imgp.toString().isNotEmpty) return imgp.toString();
    } catch (_) {}
    return 'assets/images/placeholder.png';
  }

  String _name(dynamic p) {
    try {
      final n = (p as dynamic).name;
      if (n != null) return n.toString();
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final price = _toDouble((product as dynamic).price);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ListTile(
        leading: Image.asset(
          _imagePath(product),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 60,
            height: 60,
            color: Colors.grey.shade200,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          ),
        ),
        title: Text(
          _name(product),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Harga: Rp ${price.toStringAsFixed(0)}'),
        trailing: const Text(
          'x1',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
