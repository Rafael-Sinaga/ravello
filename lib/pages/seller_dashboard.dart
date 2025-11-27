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

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  String storeName = 'Nama Toko';
  String? _profileImagePath; // foto profil / toko

  @override
  void initState() {
    super.initState();
    _loadStoreName();
    _loadProfileImage();
  }

  Future<void> _loadStoreName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      storeName = prefs.getString('storeName') ?? 'Nama Toko';
    });
  }

  Future<void> _loadProfileImage() async {
    final path = await AuthService.getProfileImagePath();
    if (!mounted) return;
    setState(() {
      _profileImagePath = path;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Sementara masih dummy untuk grafik penjualan
    final List<double> salesData = [12, 8, 14, 10, 18, 9, 15];
    final List<String> dayLabels = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min'
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===================== PROFIL TOKO =====================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
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
                  // FOTO TOKO / PROFIL DINAMIS
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFE5E7EB),
                    backgroundImage: _profileImagePath != null
                        ? (kIsWeb
                            ? NetworkImage(_profileImagePath!)
                            : FileImage(File(_profileImagePath!))
                                as ImageProvider)
                        : const AssetImage('assets/images/Profile.png'),
                    child: _profileImagePath == null
                        ? const Icon(
                            Icons.storefront_outlined,
                            size: 30,
                            color: Color(0xFF9CA3AF),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          storeName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.verified, color: Colors.green, size: 18),
                            SizedBox(width: 4),
                            Text(
                              'Terverifikasi',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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

            const SizedBox(height: 20),

            // ===================== MENU IKON =====================
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
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
                  _buildDashboardIconItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Keuangan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerFinancePage(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardIconItem(
                    icon: Icons.help_outline,
                    title: 'Pusat Bantuan',
                    onTap: () {
                      // TODO: sambungkan ke pusat bantuan / FAQ jika sudah ada
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===================== GRAFIK PENJUALAN =====================
            const Text(
              'Grafik Penjualan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '7 hari terakhir',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF6F7A74),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SalesLineChart(
                data: salesData,
                labels: dayLabels,
              ),
            ),

            const SizedBox(height: 24),

            // ===================== STATUS PESANAN =====================
            const Text(
              'Status Pesanan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.12)),
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
                  Expanded(
                    child: _buildStatusItem(
                      title: 'Perlu dikirim',
                      value: '3', // TODO: ganti dari API
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildStatusItem(
                      title: 'Pembatalan',
                      value: '0',
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: _buildStatusItem(
                      title: 'Pengembalian',
                      value: '0',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===================== AKSI CEPAT =====================
            const Text(
              'Aksi Cepat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageProductsPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.storefront,
                color: Colors.white,
              ),
              label: const Text(
                'Kelola Produk',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SellerOrderPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.receipt_long,
                color: Colors.white,
              ),
              label: const Text(
                'Lihat Transaksi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ===================== UTIL UI =====================

  static Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: Colors.grey.withOpacity(0.25),
    );
  }

  static Widget _buildStatusItem({
    required String title,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6F7A74),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardIconItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 30,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===================== WIDGET GRAFIK GARIS INTERAKTIF =====================

class SalesLineChart extends StatefulWidget {
  final List<double> data;
  final List<String> labels;

  const SalesLineChart({
    super.key,
    required this.data,
    required this.labels,
  });

  @override
  State<SalesLineChart> createState() => _SalesLineChartState();
}

class _SalesLineChartState extends State<SalesLineChart> {
  int? _selectedIndex;

  void _handleTouch(Offset localPosition, double width) {
    if (widget.data.isEmpty) return;

    const double horizontalPadding = 12;
    final double chartWidth = width - (horizontalPadding * 2);

    if (chartWidth <= 0) return;

    final double stepX =
        widget.data.length == 1 ? 0 : chartWidth / (widget.data.length - 1);
    final double x = localPosition.dx - horizontalPadding;

    int index = (x / stepX).round();
    if (index < 0) index = 0;
    if (index > widget.data.length - 1) index = widget.data.length - 1;

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);

    return LayoutBuilder(
      builder: (context, constraints) {
        final selectedIndex =
            _selectedIndex ??
                (widget.data.isNotEmpty ? widget.data.length - 1 : 0);
        final selectedValue =
            widget.data.isNotEmpty ? widget.data[selectedIndex].toInt() : 0;
        final selectedLabel =
            widget.labels.isNotEmpty ? widget.labels[selectedIndex] : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.data.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.show_chart,
                      size: 18,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$selectedValue transaksi',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $selectedLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6F7A74),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Belum ada data penjualan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F7A74),
                  ),
                ),
              ),
            SizedBox(
              height: 160,
              width: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) =>
                    _handleTouch(details.localPosition, constraints.maxWidth),
                onHorizontalDragUpdate: (details) =>
                    _handleTouch(details.localPosition, constraints.maxWidth),
                child: CustomPaint(
                  painter: _SalesLineChartPainter(
                    data: widget.data,
                    selectedIndex: _selectedIndex,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SalesLineChartPainter extends CustomPainter {
  final List<double> data;
  final int? selectedIndex;

  _SalesLineChartPainter({
    required this.data,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const Color primaryColor = Color(0xFF124170);
    const double horizontalPadding = 12;
    const double verticalPadding = 16;

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFE3ECF4)
      ..strokeWidth = 1;

    final Paint linePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    final Paint fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.25),
          primaryColor.withOpacity(0.02),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final double chartWidth = size.width - (horizontalPadding * 2);
    final double chartHeight = size.height - (verticalPadding * 2);

    if (data.isEmpty || chartWidth <= 0 || chartHeight <= 0) {
      return;
    }

    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double normalizedMax = maxValue == 0 ? 1 : maxValue;

    for (int i = 0; i <= 3; i++) {
      final double dy = verticalPadding + (chartHeight / 3.0) * i;
      canvas.drawLine(
        Offset(horizontalPadding, dy),
        Offset(size.width - horizontalPadding, dy),
        gridPaint,
      );
    }

    final Path linePath = Path();
    final Path fillPath = Path();

    final double stepX = data.length == 1 ? 0 : chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final double x = horizontalPadding + (stepX * i);
      final double value = data[i];
      final double normalized = value / normalizedMax;
      final double y =
          verticalPadding + chartHeight - (normalized * chartHeight);

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, chartHeight + verticalPadding);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }

      if (i == data.length - 1) {
        fillPath.lineTo(x, chartHeight + verticalPadding);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final Paint pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final Paint selectedPointPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2;

    final Paint selectedBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < data.length; i++) {
      final double x = horizontalPadding + (stepX * i);
      final double value = data[i];
      final double normalized = value / normalizedMax;
      final double y =
          verticalPadding + chartHeight - (normalized * chartHeight);

      if (selectedIndex != null && selectedIndex == i) {
        canvas.drawCircle(Offset(x, y), 7, selectedPointPaint);
        canvas.drawCircle(Offset(x, y), 7, selectedBorderPaint);
      } else {
        canvas.drawCircle(Offset(x, y), 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SalesLineChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
