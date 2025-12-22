// lib/pages/umkm_map_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ===================== MODEL DUMMY =====================

enum UMKMType { online, mobile }

class UMKMDummy {
  final String name;
  final UMKMType type;
  final String description;

  UMKMDummy({
    required this.name,
    required this.type,
    required this.description,
  });
}

/// ===================== PAGE =====================

class UMKMMapPage extends StatefulWidget {
  const UMKMMapPage({super.key});

  @override
  State<UMKMMapPage> createState() => _UMKMMapPageState();
}

class _UMKMMapPageState extends State<UMKMMapPage> {
  static const Color primaryColor = Color(0xFF124170);

  UMKMType? _mySellerType;

  final List<UMKMDummy> _dummyUMKM = [
    UMKMDummy(
      name: 'Kopi Keliling Pak Budi',
      type: UMKMType.mobile,
      description: 'Kopi panas & es kopi susu',
    ),
    UMKMDummy(
      name: 'Warung Bu Sari',
      type: UMKMType.online,
      description: 'Makanan rumahan',
    ),
    UMKMDummy(
      name: 'Jajanan Kang Asep',
      type: UMKMType.mobile,
      description: 'Cireng & cilok',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMySellerStatus();
  }

  Future<void> _loadMySellerStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('seller_mode');

    if (!mounted) return;

    setState(() {
      if (raw == 'mobile') {
        _mySellerType = UMKMType.mobile;
      } else if (raw == 'online') {
        _mySellerType = UMKMType.online;
      } else {
        _mySellerType = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: primaryColor,
        elevation: 1,
        title: const Text(
          'UMKM di Sekitarmu',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          /// ===== MAP PLACEHOLDER =====
          Container(
            height: 240,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F0FA),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.map_outlined,
                    size: 80,
                    color: Color(0xFF9FB3C8),
                  ),
                ),
                Positioned(
                  left: 40,
                  top: 60,
                  child: _buildMarker(UMKMType.mobile),
                ),
                Positioned(
                  right: 60,
                  bottom: 50,
                  child: _buildMarker(UMKMType.online),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _mySellerType == UMKMType.mobile
                  ? 'Kamu terlihat sebagai penjual keliling'
                  : _mySellerType == UMKMType.online
                      ? 'Toko kamu sedang online'
                      : 'Aktifkan mode jualan agar muncul di peta',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _dummyUMKM.length,
              itemBuilder: (_, i) {
                final u = _dummyUMKM[i];
                return _buildUMKMCard(u);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(UMKMType type) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: type == UMKMType.mobile ? Colors.orange : Colors.green,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Icon(
        type == UMKMType.mobile
            ? Icons.directions_walk
            : Icons.storefront,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildUMKMCard(UMKMDummy u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: u.type == UMKMType.mobile
                  ? Colors.orange.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              u.type == UMKMType.mobile
                  ? Icons.directions_walk
                  : Icons.storefront,
              color: u.type == UMKMType.mobile
                  ? Colors.orange
                  : Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  u.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: u.type == UMKMType.mobile
                  ? Colors.orange.withOpacity(0.15)
                  : Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              u.type == UMKMType.mobile ? 'Keliling' : 'Online',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: u.type == UMKMType.mobile
                    ? Colors.orange
                    : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
