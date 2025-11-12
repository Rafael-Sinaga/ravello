// lib/pages/favorite_page.dart
import 'package:flutter/material.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> favorites = [
      {
        'image': 'assets/images/Rolex_KW.png',
        'title': 'Rolex KW',
        'price': 175000,
      },
      {
        'image': 'assets/images/Gelang_Rajut.png',
        'title': 'Gelang Anyaman Rotan',
        'price': 85000,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
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
      body: favorites.isEmpty
          ? const Center(
              child: Text(
                'Belum ada produk favorit',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final fav = favorites[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        fav['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      fav['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF124170),
                      ),
                    ),
                    subtitle: Text(
                      'Rp${fav['price']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {},
                    ),
                  ),
                );
              },
            ),
    );
  }
}
