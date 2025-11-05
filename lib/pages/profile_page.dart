// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'favorite_page.dart';
import 'order_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF124170), size: 22),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Text(
                'Profil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF124170),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== CARD PROFIL USER =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/images/Profile.png'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Halo,',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF6F7D8D),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Budi Sigma',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF124170),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'budisigma69@gmail.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFFB0B9C3),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      // TODO: arahkan ke Edit Profile page jika ada
                      Navigator.pushNamed(context, '/editProfile');
                    },
                    child: Row(
                      children: const [
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF124170),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.edit_outlined,
                            color: Color(0xFF124170), size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ===== CONTAINER AKUN SAYA =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Akun Saya',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF124170),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Pesanan saya -> buka OrderPage (buyer flow)
                  _buildMenuCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Pesanan saya',
                    subtitle: 'Tinjau pesanan sebelum dan sekarang',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrderPage(),
                        ),
                      );
                    },
                  ),

                  // Notifikasi -> named route (gantikan jika berbeda)
                  _buildMenuCard(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi',
                    subtitle: 'Tinjau semua notifikasi',
                    onTap: () {
                      // jika lu punya halaman notifikasi, daftarkan route di main.dart
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),

                  // Favorit -> buka FavoritePage
                  _buildMenuCard(
                    icon: Icons.favorite_border_rounded,
                    title: 'Favorit Saya',
                    subtitle: 'Tinjau barang favoritmu',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoritePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // ===== CONTAINER MULAI JUAL =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai Jual',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF124170),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildMenuCard(
                    icon: Icons.storefront_outlined,
                    title: 'Buka Toko Sekarang',
                    subtitle: 'Jual produkmu dan mulai hasilkan pendapatan',
                    onTap: () {
                      // named route; daftarkan '/registerSeller' di main.dart jika belum ada
                      Navigator.pushNamed(context, '/registerSeller');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const Navbar(currentIndex: 2),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: const Color(0xFF124170), size: 28),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF124170),
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF6F7D8D),
            fontSize: 13,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.black38,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
