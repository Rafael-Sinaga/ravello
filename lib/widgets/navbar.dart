// lib/widgets/navbar.dart
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  final int currentIndex; // parameter baru agar bisa sinkron antar halaman

  const Navbar({
    super.key,
    required this.currentIndex,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; // set index aktif dari luar
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // hindari reload halaman yang sama
    setState(() => _selectedIndex = index);

    // Navigasi antar halaman
    switch (index) {
      case 0: // Beranda
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Keranjang
        Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 2: // Profil
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // sesuai desain Figma
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.20),
            offset: const Offset(0, -3),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0, // karena shadow custom udah ada
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
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
