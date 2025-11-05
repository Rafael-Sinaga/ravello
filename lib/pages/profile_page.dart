// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      // isi halaman profil
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          children: [
            // Foto profil + nama
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/default_user.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nama Pengguna',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user@email.com',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Menu pengaturan akun
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    onTap: () {
                      // nanti arahkan ke halaman edit profil
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Pesanan',
                    onTap: () {
                      // arahkan ke halaman riwayat pesanan
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_border,
                    title: 'Favorit Saya',
                    onTap: () {
                      Navigator.pushNamed(context, '/favorite');
                      // arahkan ke wishlist atau favorit
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan Akun',
                    onTap: () {
                      // halaman pengaturan
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Keluar',
                    onTap: () {
                      // log out
                    },
                    isLogout: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Navbar di bagian bawah
      bottomNavigationBar: const Navbar(currentIndex: 2), // sesuai urutan: 0=home,1=cart,2=profile
    );
  }

  // Widget helper buat item menu
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          color: isLogout ? Colors.redAccent : Colors.black87,
          fontWeight: isLogout ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
