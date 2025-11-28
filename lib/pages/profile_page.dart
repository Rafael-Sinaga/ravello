// lib/pages/profile_page.dart
// === PROFILE PAGE FINAL ===

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'order_page.dart';
import '../widgets/navbar.dart';
import 'verify_seller_page.dart';
import 'onboarding.dart';
import '../services/auth_service.dart';
import 'seller_dashboard.dart'; // untuk navigasi langsung ke profil penjual

// ======================================================
// ========== CUSTOMER SERVICE PAGE (NO LAUNCHER) ========
// ======================================================

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Layanan Customer Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: primaryColor),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FBFD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Hubungi Customer Service',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Jika Anda memiliki pertanyaan atau membutuhkan bantuan, silakan hubungi layanan pelanggan melalui detail berikut:',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Email:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text('support@tokoapp.com'),
              SizedBox(height: 16),
              Text(
                'Jam Operasional:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text('Senin - Jumat, 08.00 - 17.00 WIB'),
            ],
          ),
        ),
      ),
    );
  }
}

// ======================================================
// ======================= FAQ PAGE =====================
// ======================================================

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: primaryColor),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF8FBFD),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ExpansionTile(
            title: Text('Bagaimana cara melakukan pemesanan?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Anda dapat melakukan pemesanan melalui halaman produk dan memilih tombol "Tambah ke Keranjang".'),
              )
            ],
          ),
          ExpansionTile(
            title: Text('Bagaimana cara menghubungi penjual?'),
            children: [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                    'Anda dapat menghubungi penjual melalui halaman produk yang menyediakan fitur kontak.'),
              )
            ],
          ),
        ],
      ),
    );
  }
}

// ======================================================
// ===================== PROFILE PAGE ====================
// ======================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _overrideName;
  String? _overrideDescription;
  String? _profileImagePath; // path foto profil
  String? _phoneNumber; // nomor telepon

  bool _isSeller = false; // ← STATE LOKAL STATUS PENJUAL

  @override
  void initState() {
    super.initState();
    print('User saat ini di ProfilePage: ${AuthService.currentUser?.name}');
    _loadSellerStatus();
    _loadLocalDescription();
    _loadProfileImage();
    _loadLocalNameAndPhone();
  }

  Future<void> _loadSellerStatus() async {
    // gunakan AuthService supaya sinkron dengan SharedPreferences
    final status = await AuthService.getSellerStatus();
    if (!mounted) return;
    setState(() {
      _isSeller = status;
    });
  }

  Future<void> _refreshSellerStatus() async {
    await _loadSellerStatus();
    _loadLocalDescription();
    _loadProfileImage();
    _loadLocalNameAndPhone();
  }

  Future<void> _loadLocalDescription() async {
    final prefs = await SharedPreferences.getInstance();
    final desc = prefs.getString('user_description');
    if (!mounted) return;
    if (desc != null && desc.isNotEmpty) {
      setState(() => _overrideDescription = desc);
    }
  }

  Future<void> _loadLocalNameAndPhone() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('current_user_name');
    final savedPhone = prefs.getString('user_phone');

    if (!mounted) return;
    setState(() {
      _overrideName = savedName;
      _phoneNumber = savedPhone;
    });
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (!mounted) return;
    setState(() => _profileImagePath = path);
  }

  // =============== SHEET EDIT PROFIL (NAMA + NO HP) ===============
  void _openEditProfileSheet() async {
    final nameController = TextEditingController(
      text: _overrideName ?? AuthService.currentUser?.name ?? '',
    );
    final phoneController = TextEditingController(
      text: _phoneNumber ?? '',
    );
    final descController = TextEditingController(
      text: _overrideDescription ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(
                    thickness: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Edit Profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF124170),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi singkat',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newPhone = phoneController.text.trim();
                        final newDesc = descController.text.trim();

                        if (newName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Nama tidak boleh kosong')),
                          );
                          return;
                        }

                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setString('current_user_name', newName);
                        await prefs.setString('user_phone', newPhone);
                        await prefs.setString('user_description', newDesc);

                        // ❌ TIDAK LAGI edit AuthService.currentUser!.name
                        // cukup pakai override + prefs

                        if (!mounted) return;
                        setState(() {
                          _overrideName = newName;
                          _overrideDescription = newDesc;
                          _phoneNumber = newPhone;
                        });

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF124170),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);
    const Color lightBackground = Color(0xFFF8FBFD);

    final nameToShow =
        _overrideName ?? AuthService.currentUser?.name ?? 'Pengguna';
    final emailToShow =
        AuthService.currentUser?.email ?? 'Email tidak tersedia';
    final descToShow = _overrideDescription;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const HomePage(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: lightBackground,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryColor, size: 26),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          title: const Text(
            'Profil',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= KARTU PROFIL ===================
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // FOTO PROFIL DINAMIS
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: const Color(0xFFE5E7EB),
                      backgroundImage: _profileImagePath != null
                          ? (kIsWeb
                              ? NetworkImage(_profileImagePath!)
                              : FileImage(File(_profileImagePath!))
                                  as ImageProvider)
                          : null,
                      child: _profileImagePath == null
                          ? const Icon(
                              Icons.person,
                              size: 32,
                              color: Color(0xFF9CA3AF),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: GestureDetector(
                        onTap: _openEditProfileSheet,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halo,',
                              style: TextStyle(
                                  color: Color(0xFF6F7A74), fontSize: 13),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nameToShow,
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                            Text(
                              emailToShow,
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            if (_phoneNumber != null &&
                                _phoneNumber!.trim().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _phoneNumber!,
                                  style: const TextStyle(
                                    color: Color(0xFF6F7A74),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            if (descToShow != null && descToShow.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  descToShow,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // === Tombol Penjual (Dinamis) ===
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 22),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_isSeller) {
                      // sudah penjual → ke dashboard
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SellerDashboardPage()),
                      ).then((_) {
                        _refreshSellerStatus();
                      });
                    } else {
                      // belum penjual → ke proses verifikasi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const VerifySellerPage()),
                      ).then((_) {
                        _refreshSellerStatus();
                      });
                    }
                  },
                  icon: const Icon(Icons.storefront_rounded, size: 20),
                  label: Text(
                    _isSeller ? 'Toko Saya' : 'Daftar sebagai Penjual',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor.withOpacity(0.95),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // ================== AKUN SAYA ===================
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Akun Saya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              Container(
                decoration: _box(),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.inventory_2_outlined,
                      title: 'Pesanan saya',
                      subtitle: 'Tinjau pesanan sebelum dan sekarang',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrderPage()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorit Saya',
                      subtitle: 'Tinjau barang favoritmu',
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/favorite'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // =============== LAINNYA (FAQ + CUSTOMER SERVICE) ===============
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Lainnya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              Container(
                decoration: _box(),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      subtitle: 'Pertanyaan yang sering diajukan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FAQPage()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.headset_mic_outlined,
                      title: 'Layanan Customer Service',
                      subtitle: 'Hubungi layanan pelanggan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerServicePage()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ==================== LOGOUT ======================
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Konfirmasi Keluar'),
                          content: const Text(
                              'Apakah Anda yakin ingin keluar dari akun ini?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Batal'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor),
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              child: const Text('Keluar'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await AuthService.logout();
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OnboardingPage()),
                          (route) => false,
                        );
                      }
                    },
                    icon:
                        const Icon(Icons.logout_rounded, color: primaryColor),
                    label: const Text(
                      'Keluar',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFB6C7D6),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                        side: const BorderSide(
                            color: primaryColor, width: 0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const Navbar(currentIndex: 2),
      ),
    );
  }

  // ======== UI UTILITIES ========

  BoxDecoration _box() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.withOpacity(0.15)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 5,
          offset: const Offset(0, 3),
        )
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    const Color primaryColor = Color(0xFF124170);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6F7A74),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Color(0xFF6F7A74),
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
