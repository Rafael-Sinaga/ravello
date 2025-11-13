import 'package:flutter/material.dart';
import 'home_page.dart';
import 'order_page.dart';
import '../widgets/navbar.dart';
import 'verify_seller_page.dart';
import 'onboarding.dart';
import '../services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // Debug: pastikan data user terbaca
    print('User saat ini di ProfilePage: ${AuthService.currentUser?.name}');
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);
    const Color lightBackground = Color(0xFFF8FBFD);

    final user = AuthService.currentUser;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (context, animation, secondaryAnimation) =>
                const HomePage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Kartu Profil ===
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
                    const CircleAvatar(
                      radius: 32,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
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
                          Text(
                            user?.name ?? 'Pengguna',
                            style: const TextStyle(
                              color: primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.email ?? 'Email tidak tersedia',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Row(
                        children: const [
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.edit, size: 16, color: primaryColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // === Tombol Daftar Sebagai Penjual ===
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 22),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerifySellerPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.storefront_rounded, size: 20),
                  label: const Text(
                    'Daftar sebagai Penjual',
                    style: TextStyle(
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
                    elevation: 3,
                    shadowColor: primaryColor.withOpacity(0.25),
                  ),
                ),
              ),

              // === Judul Akun Saya ===
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

              // === Kartu Menu Akun Saya ===
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
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
                            builder: (context) => const OrderPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.notifications_none_rounded,
                      title: 'Notifikasi',
                      subtitle: 'Tinjau semua notifikasimu',
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.favorite_border_rounded,
                      title: 'Favorit Saya',
                      subtitle: 'Tinjau barang favoritmu',
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/favorite');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === Judul Pengaturan (baru) ===
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  'Pengaturan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),

              // === Kartu Menu Pengaturan ===
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.language,
                      title: 'Bahasa',
                      subtitle: 'Pilih bahasa aplikasi',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguagePage(),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _buildMenuItem(
                      context,
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      subtitle: 'Pertanyaan yang sering diajukan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FAQPage(),
                          ),
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
                            builder: (context) => const CustomerServicePage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // === Tombol Keluar ===
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
onPressed: () async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Konfirmasi Keluar'),
      content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
           child: const Text('Batal'),
             ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF124170),
                    ),
                      onPressed: () => Navigator.pop(context, true),
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
                        MaterialPageRoute(builder: (context) => const OnboardingPage()),
                        (route) => false,
                        );
                      }
                    },

                    icon: const Icon(Icons.logout_rounded, color: primaryColor),
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
                        side: const BorderSide(color: primaryColor, width: 0.5),
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

/// -------------------- HALAMAN PLACEHOLDER --------------------
/// Halaman ini sederhana; ganti kontennya nanti sesuai requirement backend/UI.

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bahasa'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pilih Bahasa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Card(
            child: RadioListTile<String>(
              value: 'id',
              groupValue: 'id', // sementara default
              title: const Text('Bahasa Indonesia'),
              onChanged: (val) {
                // implementasi ganti bahasa nanti
              },
            ),
          ),
          Card(
            child: RadioListTile<String>(
              value: 'en',
              groupValue: 'id',
              title: const Text('English'),
              onChanged: (val) {
                // implementasi ganti bahasa nanti
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Pertanyaan yang sering diajukan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          ExpansionTile(
            title: Text('Bagaimana cara menjadi penjual?'),
            children: [Padding(padding: EdgeInsets.all(12), child: Text('Isi penjelasan singkat proses pendaftaran...'))],
          ),
          ExpansionTile(
            title: Text('Metode pembayaran apa yang tersedia?'),
            children: [Padding(padding: EdgeInsets.all(12), child: Text('Contoh: OVO, DANA, COD, dsb.'))],
          ),
          ExpansionTile(
            title: Text('Bagaimana mengajukan keluhan?'),
            children: [Padding(padding: EdgeInsets.all(12), child: Text('Hubungi customer service lewat menu layanan.'))],
          ),
        ],
      ),
    );
  }
}

class CustomerServicePage extends StatelessWidget {
  const CustomerServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Customer Service'),
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hubungi Kami', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Telepon'),
              subtitle: const Text('+62 812-3456-7890'),
              onTap: () {
                // panggil telepon jika ingin
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chat (WhatsApp)'),
              subtitle: const Text('cs@ravello.id'),
              onTap: () {
                // buka chat
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: const Text('support@ravello.id'),
              onTap: () {
                // buka email client
              },
            ),
            const SizedBox(height: 18),
            const Text('Jam Operasional', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Senin - Jumat: 09:00 - 17:00\nSabtu: 09:00 - 13:00\nMinggu & Hari Libur: Tutup'),
          ],
        ),
      ),
    );
  }
}
