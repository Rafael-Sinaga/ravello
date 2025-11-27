// lib/pages/seller_order_page.dart
import 'package:flutter/material.dart';
import 'seller_order_page_detail.dart';

class SellerOrderPage extends StatefulWidget {
  const SellerOrderPage({super.key});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  String _selectedFilter = 'Semua';

  // Dummy data pesanan untuk ilustrasi
  late List<SellerOrder> _orders;

  @override
  void initState() {
    super.initState();
    _orders = [
      SellerOrder(
        id: 'INV-23001',
        buyerName: 'Budi Santoso',
        address: 'Rumah Utama • Jl. Contoh No. 123, Jakarta Selatan',
        status: 'Baru',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        total: 350000,
        paymentMethod: 'Transfer Bank',
        items: [
          SellerOrderItem(
            name: 'FC Barcelona Home 08/09',
            variant: 'Size M',
            qty: 1,
            price: 350000,
          ),
        ],
        note: 'Tolong kirim sebelum hari Sabtu, makasih kak.',
      ),
      SellerOrder(
        id: 'INV-23002',
        buyerName: 'Rina Putri',
        address: 'Kost Rina • Jl. Melati No. 45, Bandung',
        status: 'Diproses',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        total: 520000,
        paymentMethod: 'Transfer Bank',
        items: [
          SellerOrderItem(
            name: 'Real Madrid Away 22/23',
            variant: 'Size L',
            qty: 1,
            price: 520000,
          ),
        ],
      ),
      SellerOrder(
        id: 'INV-22987',
        buyerName: 'Andi Kurniawan',
        address: 'Perumahan Hijau Indah Blok B2, Bekasi',
        status: 'Dikirim',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        total: 275000,
        paymentMethod: 'COD',
        items: [
          SellerOrderItem(
            name: 'AC Milan Home 21/22',
            variant: 'Size S',
            qty: 1,
            price: 275000,
          ),
        ],
      ),
      SellerOrder(
        id: 'INV-22950',
        buyerName: 'Siti Aminah',
        address: 'Jl. Kenanga No. 88, Surabaya',
        status: 'Selesai',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        total: 410000,
        paymentMethod: 'Transfer Bank',
        items: [
          SellerOrderItem(
            name: 'Manchester City Home 20/21',
            variant: 'Size M',
            qty: 1,
            price: 410000,
          ),
        ],
      ),
    ];
  }

  List<SellerOrder> get _filteredOrders {
    if (_selectedFilter == 'Semua') return _orders;
    return _orders.where((o) => o.status == _selectedFilter).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Baru':
        return const Color(0xFF2563EB);
      case 'Diproses':
        return const Color(0xFFF59E0B);
      case 'Dikirim':
        return const Color(0xFF0EA5E9);
      case 'Selesai':
        return const Color(0xFF16A34A);
      default:
        return primaryColor;
    }
  }

  String _formatPrice(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  String _formatShortTime(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pesanan Masuk',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // FILTER STATUS
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'),
                  _buildFilterChip('Baru'),
                  _buildFilterChip('Diproses'),
                  _buildFilterChip('Dikirim'),
                  _buildFilterChip('Selesai'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: _filteredOrders.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada pesanan untuk status ini',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6F7A74),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SellerOrderPageDetail(order: order),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.16),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: status + jam
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(order.status)
                                          .withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 8,
                                          color: _statusColor(order.status),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          order.status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: _statusColor(order.status),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    _formatShortTime(order.createdAt),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6F7A74),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Text(
                                'ID Pesanan: ${order.id}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),

                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5ECF4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.person_outline,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          order.buyerName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          order.address,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF6F7A74),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              const Divider(
                                height: 1,
                                color: Color(0xFFE5E7EB),
                              ),
                              const SizedBox(height: 8),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.items.length} produk',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF6F7A74),
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_formatPrice(order.total)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF6F7A74),
          ),
        ),
        selected: isSelected,
        selectedColor: primaryColor,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: isSelected ? primaryColor : const Color(0xFFE5E7EB),
        ),
        onSelected: (_) {
          setState(() {
            _selectedFilter = label;
          });
        },
      ),
    );
  }
}
