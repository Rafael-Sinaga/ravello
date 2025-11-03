// navbar.dart
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 1) {
      // index 1 = ikon keranjang
      Navigator.pushNamed(context, '/cart');
    }
    // index 0 = beranda, tidak melakukan navigasi
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // warna navbar putih
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.20), // #000000 @ 20%
            offset: const Offset(0, -3), // X=0, Y=-3 (shadow di atas)
            blurRadius: 10, // Blur = 10
            spreadRadius: 0, // Spread = 0
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0, // gunakan shadow custom, bukan shadow default
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF124170),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              label: 'Keranjang',
            ),
          ],
        ),
      ),
    );
  }
}
