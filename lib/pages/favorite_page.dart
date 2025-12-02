import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favoriteKeys = [];
  List<Product> _allProducts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavoritesAndProducts();
  }

  Future<void> _loadFavoritesAndProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favorites') ?? <String>[];

      final products = await ProductService.fetchProducts();

      if (!mounted) return;
      setState(() {
        favoriteKeys = favs;
        _allProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      final favs = prefs.getStringList('favorites') ?? <String>[];

      if (!mounted) return;
      setState(() {
        favoriteKeys = favs;
        _error = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  Product? _getProductFromKey(String key) {
    for (var p in _allProducts) {
      final id = '${p.name}_${p.price}_${p.imagePath}';
      if (id == key) return p;
    }
    return null;
  }

  Future<void> _removeFavorite(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? <String>[];

    favs.remove(key);
    await prefs.setStringList('favorites', favs);

    setState(() {
      favoriteKeys = favs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favProducts = favoriteKeys
        .map((k) => _getProductFromKey(k))
        .where((p) => p != null)
        .cast<Product>()
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/profile');
          },
        ),
        title: const Text(
          'Favorit Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF124170),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8FBFD),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF124170)),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: _loadFavoritesAndProducts,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : favProducts.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada produk favorit',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: favProducts.length,
                      itemBuilder: (context, index) {
                        final p = favProducts[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 6,
                              )
                            ],
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: p.imagePath.startsWith('http')
                                  ? Image.network(
                                      p.imagePath,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                    )
                                  : Image.asset(
                                      p.imagePath,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            title: Text(
                              p.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF124170),
                              ),
                            ),
                            subtitle: Text(
                              'Rp ${p.price.round()}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeFavorite(
                                '${p.name}_${p.price}_${p.imagePath}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
