// lib/pages/seller_dashboard.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_service.dart';
import 'profile_page.dart';
import 'manage_products_page.dart';
import 'seller_finance_page.dart';
import 'seller_order_page.dart';
import 'edit_store_page.dart';

/// ===================== SELLER MODE =====================

enum SellerMode { online, mobile, offline }

SellerMode parseSellerMode(String? raw) {
  switch (raw) {
    case 'mobile':
      return SellerMode.mobile;
    case 'offline':
      return SellerMode.offline;
    case 'online':
    default:
      return SellerMode.online;
  }
}

/// ===================== PAGE =====================

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFE9F0FA);

  String storeName = 'Nama Toko';
  String storeDescription = 'Toko terpercaya di Ravello';
  String? storeImagePath;

  SellerMode _sellerMode = SellerMode.online; // ✅ DEFAULT ONLINE

  @override
  void initState() {
    super.initState();
    _initDashboard();
    _loadSellerMode();
  }

  /// ===================== SELLER MODE =====================

  Future<void> _loadSellerMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('seller_mode');

    // 🔥 JIKA BELUM ADA MODE → AUTO ONLINE
    if (raw == null) {
      await prefs.setString('seller_mode', 'online');
      if (!mounted) return;
      setState(() {
        _sellerMode = SellerMode.online;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _sellerMode = parseSellerMode(raw);
    });
  }

  /// ===================== STORE DATA =====================

  Future<void> _initDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    final storeId = prefs.getInt('storeId');

    if (storeId != null) {
      try {
        final result = await AuthService.getStoreProfile();
        if (result['success'] == true && mounted) {
          final data = result['data'];
          setState(() {
            storeName =
                data['storeName'] ?? prefs.getString('storeName') ?? storeName;
            storeDescription = data['description'] ??
                prefs.getString('storeDescription') ??
                storeDescription;
            storeImagePath =
                data['imagePath'] ?? prefs.getString('storeImagePath');
          });
          return;
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      storeName = prefs.getString('storeName') ?? storeName;
      storeDescription =
          prefs.getString('storeDescription') ?? storeDescription;
      storeImagePath = prefs.getString('storeImagePath');
    });
  }

  Future<void> _openEditStorePage() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EditStorePage()),
    );
    if (updated == true) {
      _initDashboard();
    }
  }

  void _openBoostBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _BoostBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final salesData = <double>[12, 8, 14, 10, 18, 9, 15];
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        foregroundColor: primaryColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            );
          },
        ),
        title: const Text(
          'Profil Penjual',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _openEditStorePage,
                borderRadius: BorderRadius.circular(20),
                child: _StoreHeader(
                  storeName: storeName,
                  storeDescription: storeDescription,
                  storeImagePath: storeImagePath,
                  sellerMode: _sellerMode,
                ),
              ),
              const SizedBox(height: 18),

              _QuickMenu(onBoost: _openBoostBottomSheet),

              const SizedBox(height: 22),
              const Text(
                'Grafik Penjualan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: primaryColor,
                ),
              ),
              const Text(
                '7 hari terakhir',
                style: TextStyle(fontSize: 11, color: Color(0xFF6F7A74)),
              ),
              const SizedBox(height: 10),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFEFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: SalesLineChart(
                  data: salesData,
                  labels: dayLabels,
                ),
              ),

              const SizedBox(height: 22),

              _ActionButtons(
                onManageProduct: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageProductsPage()),
                  );
                },
                onOrders: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SellerOrderPage()),
                  );
                },
                onBoost: _openBoostBottomSheet,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== HEADER =====================

class _StoreHeader extends StatelessWidget {
  final String storeName;
  final String storeDescription;
  final String? storeImagePath;
  final SellerMode sellerMode;

  const _StoreHeader({
    required this.storeName,
    required this.storeDescription,
    required this.storeImagePath,
    required this.sellerMode,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF124170);

    Color badgeColor;
    String badgeText;
    IconData badgeIcon;

    switch (sellerMode) {
      case SellerMode.mobile:
        badgeColor = Colors.orange;
        badgeText = 'Keliling';
        badgeIcon = Icons.directions_walk;
        break;
      case SellerMode.offline:
        badgeColor = Colors.grey;
        badgeText = 'Offline';
        badgeIcon = Icons.pause_circle_filled;
        break;
      case SellerMode.online:
      default:
        badgeColor = Colors.green;
        badgeText = 'Online';
        badgeIcon = Icons.storefront;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF3F7FF)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: (storeImagePath != null &&
                    storeImagePath!.isNotEmpty)
                ? (kIsWeb
                    ? NetworkImage(storeImagePath!)
                    : FileImage(File(storeImagePath!)) as ImageProvider)
                : null,
            child: storeImagePath == null
                ? const Icon(Icons.storefront_outlined,
                    color: Color(0xFF9CA3AF))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 14, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  storeDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF6F7A74)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== OTHERS =====================

class _QuickMenu extends StatelessWidget {
  final VoidCallback onBoost;
  const _QuickMenu({required this.onBoost});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF124170);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.account_balance_wallet_rounded,
                  color: primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SellerFinancePage()),
                );
              },
            ),
          ),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.rocket_launch_rounded,
                  color: primaryColor),
              onPressed: onBoost,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onManageProduct;
  final VoidCallback onOrders;
  final VoidCallback onBoost;

  const _ActionButtons({
    required this.onManageProduct,
    required this.onOrders,
    required this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF124170);

    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: onManageProduct,
          icon: const Icon(Icons.inventory_2_rounded),
          label: const Text('Kelola Produk'),
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: onOrders,
          icon: const Icon(Icons.receipt_long_rounded),
          label: const Text('Lihat Transaksi'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),
      ],
    );
  }
}

class SalesLineChart extends StatelessWidget {
  final List<double> data;
  final List<String> labels;

  const SalesLineChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Text(
          '(${data.length} data • ${labels.length} label)',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

class _BoostBottomSheet extends StatelessWidget {
  const _BoostBottomSheet();

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF124170);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Boost Produk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Fitur dummy. Akan aktif setelah backend siap.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
