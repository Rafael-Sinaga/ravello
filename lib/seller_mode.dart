// lib/pages/seller_mode.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SellerModePage extends StatefulWidget {
  const SellerModePage({super.key});

  @override
  State<SellerModePage> createState() => _SellerModePageState();
}

class _SellerModePageState extends State<SellerModePage> {
  static const Color primaryColor = Color(0xFF124170);

  /// true = seller sedang keliling (mobile)
  bool isMobileMode = false;

  @override
  void initState() {
    super.initState();
    _setOnlineAutomatically();
    _loadSellerMode();
  }

  /// 🔥 ONLINE otomatis saat halaman dibuka
  Future<void> _setOnlineAutomatically() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('seller_mode', 'online');
  }

  /// Load apakah seller sedang mobile
  Future<void> _loadSellerMode() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString('seller_mode');

    setState(() {
      isMobileMode = mode == 'mobile';
    });
  }

  /// Toggle mode keliling
  Future<void> _toggleMobileMode() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isMobileMode = !isMobileMode;
    });

    await prefs.setString(
      'seller_mode',
      isMobileMode ? 'mobile' : 'online',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isMobileMode
              ? 'Mode keliling aktif. Lokasi kamu bisa ditemukan pembeli.'
              : 'Mode keliling dimatikan. Kamu tetap online.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Mode Jualan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== STATUS CARD =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green, // selalu online
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Kamu ONLINE dan bisa ditemukan pembeli',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ===== MOBILE STATUS =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isMobileMode
                    ? const Color(0xFFE0F2FE)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_walk_rounded,
                    color: isMobileMode
                        ? const Color(0xFF0284C7)
                        : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isMobileMode
                          ? 'Mode keliling aktif (lokasi bergerak)'
                          : 'Mode keliling tidak aktif',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Mode keliling cocok untuk UMKM seperti penjual kopi, makanan, atau jajanan yang berpindah lokasi.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // ===== MAP PLACEHOLDER =====
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Peta akan aktif saat mode keliling dinyalakan',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),

            const Spacer(),

            // ===== ACTION BUTTON =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _toggleMobileMode,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isMobileMode ? Colors.redAccent : primaryColor,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isMobileMode
                      ? 'Matikan Mode Keliling'
                      : 'Aktifkan Mode Keliling',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
