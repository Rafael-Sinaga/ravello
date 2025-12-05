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
    const Color lightBackground = Color(0xFFF8FBFD);

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
        centerTitle: true,
      ),
      backgroundColor: lightBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // HEADER CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF124170),
                    Color(0xFF1C6BA4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Butuh Bantuan?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tim customer service kami siap membantu pertanyaan dan kendala transaksi Anda.',
                          style: TextStyle(
                            color: Color(0xFFE5EDF6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // KONTEN DETAIL KONTAK
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hubungi Customer Service',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Jika Anda memiliki pertanyaan atau membutuhkan bantuan, silakan hubungi layanan pelanggan melalui detail berikut:',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Email row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE5EDFF),
                        child: Icon(
                          Icons.email_outlined,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'support@tokoapp.com',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Jam operasional
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFE2F4E8),
                        child: Icon(
                          Icons.access_time_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jam Operasional',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                                fontSize: 13,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Senin - Jumat, 08.00 - 17.00 WIB',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF4B5563),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 12),

                  // Info respons
                  Row(
                    children: const [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: primaryColor,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Balasan biasanya diterima dalam waktu kurang dari 1x24 jam pada hari kerja.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
    const Color lightBackground = Color(0xFFF8FBFD);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FAQ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: primaryColor),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: lightBackground,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFE5EDFF),
                  child: Icon(
                    Icons.help_outline_rounded,
                    color: primaryColor,
                    size: 26,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Beberapa pertanyaan yang sering diajukan terkait pemesanan dan komunikasi dengan penjual.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Pertanyaan Umum',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // LIST FAQ KARTU
          _FaqItem(
            question: 'Bagaimana cara melakukan pemesanan?',
            answer:
                'Anda dapat melakukan pemesanan melalui halaman produk dan memilih tombol "Tambah ke Keranjang". Setelah itu, lanjutkan ke halaman keranjang dan ikuti langkah checkout hingga pembayaran selesai.',
          ),
          const SizedBox(height: 10),
          _FaqItem(
            question: 'Bagaimana cara menghubungi penjual?',
            answer:
                'Anda dapat menghubungi penjual melalui halaman produk yang menyediakan fitur kontak. Gunakan fitur pesan untuk menanyakan detail produk, pengiriman, atau hal lain sebelum melakukan pembelian.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: primaryColor.withOpacity(0.06),
          highlightColor: primaryColor.withOpacity(0.03),
        ),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          childrenPadding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 14),
          iconColor: primaryColor,
          collapsedIconColor: const Color(0xFF6F7A74),
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
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

  /// 🔥 SEKARANG MURNI PAKAI FLAG LOKAL
  /// TIDAK LAGI MENGGUNAKAN AuthService.getSellerStatus()
  Future<void> _loadSellerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localFlag = prefs.getBool('isSeller_local') ?? false;

      if (!mounted) return;
      setState(() {
        _isSeller = localFlag;
      });

      print('PROFILE _isSeller (from local isSeller_local) = $_isSeller');
    } catch (e) {
      print('Gagal load seller status dari SharedPreferences: $e');
    }
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
                  gradient: const LinearGradient(
                    colors: [
                      Colors.white,
                      Color(0xFFE7F1FA),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // FOTO PROFIL DINAMIS + RING GRADIENT
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF124170),
                            Color(0xFF1C6BA4),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white,
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
                                color: Color(0xFF6F7A74),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    nameToShow,
                                    style: const TextStyle(
                                      color: primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: primaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              emailToShow,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            if (_phoneNumber != null &&
                                _phoneNumber!.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _phoneNumber!,
                                style: const TextStyle(
                                  color: Color(0xFF6F7A74),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (descToShow != null &&
                                descToShow.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                descToShow,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isSeller
                                        ? const Color(0xFFE2F4E8)
                                        : const Color(0xFFE5EDFF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _isSeller
                                            ? Icons.store_mall_directory_rounded
                                            : Icons.person_outline_rounded,
                                        size: 14,
                                        color: primaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _isSeller
                                            ? 'Akun Penjual Aktif'
                                            : 'Akun Pembeli',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                          builder: (context) => const SellerDashboardPage(),
                        ),
                      ).then((_) {
                        _refreshSellerStatus();
                      });
                    } else {
                      // belum penjual → ke proses verifikasi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VerifySellerPage(),
                        ),
                      ).then((_) {
                        _refreshSellerStatus();
                      });
                    }
                  },
                  icon: const Icon(Icons.storefront_rounded, size: 20),
                  label: Text(
                    _isSeller ? 'Lihat Toko' : 'Daftar sebagai Penjual',
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
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                    shadowColor: primaryColor.withOpacity(0.3),
                  ),
                ),
              ),

              // ================== AKUN SAYA ===================
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Akun Saya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
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
                            builder: (_) => const OrderPage(),
                          ),
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
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Lainnya',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
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
                            builder: (context) => const OnboardingPage(),
                          ),
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
