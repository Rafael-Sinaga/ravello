// lib/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../providers/address_provider.dart';
import '../models/product_model.dart';
import 'order_page.dart';
import 'edit_address_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  static const List<String> bankNames = [
    'BCA',
    'Bank Mandiri',
    'BNI',
    'BRI',
  ];

  // ikon untuk setiap metode pembayaran (urutannya sama dengan "methods")
  static const List<String> paymentIcons = [
    'assets/images/Paylater.png', // PayLater
    'assets/images/Dana.png',     // DANA
    'assets/images/COD.png',      // COD
    'assets/images/OVO.png',      // OVO
    'assets/images/bank.png',     // Transfer Bank
  ];

  // ikon untuk setiap bank (urutannya sama dengan "bankNames")
  static const List<String> bankIcons = [
    'assets/images/BCA.png',     // BCA
    'assets/images/Mandiri.png', // Mandiri
    'assets/images/BNI.png',     // BNI
    'assets/images/BRI.png',     // BRI
  ];

  int _selectedShipping = 0;
  int _selectedPayment = 0;
  int? _selectedBank; // index bank yang dipilih (kalau transfer bank)

  double _sliderValue = 0.0;
  bool _isSliding = false;

  // ==================== LOGIKA KONFIRMASI ====================
  void _handleConfirmPayment() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk di keranjang untuk di-checkout.'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    // Ambil produk pertama dari keranjang (sementara 1 produk)
    final Product product = cart.items.first;

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.addOrder(product);

    // Opsional: hapus produk dari keranjang
    cart.removeItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pesanan dikonfirmasi!'),
        backgroundColor: primaryColor,
      ),
    );

    // Arahkan ke halaman "Pesanan Saya"
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OrderPage()),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final Product? product = cart.items.isNotEmpty ? cart.items.first : null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // kalau mau pakai bantuan / CS di checkout, taruh logic di sini
            },
            icon: const Icon(
              Icons.headset_mic_outlined,
              color: primaryColor,
            ),
          ),
        ],
      ),
      body: product == null
          ? const Center(
              child: Text(
                'Tidak ada produk untuk di-checkout.\nSilakan tambahkan produk ke keranjang dulu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6F7A74),
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // ================== ALAMAT PENGIRIMAN ==================
                      _buildAddressCard(),

                      const SizedBox(height: 14),

                      // ================== PENGIRIMAN ==================
                      _buildShippingCard(),

                      const SizedBox(height: 14),

                      // ================== METODE PEMBAYARAN ==================
                      _buildPaymentCard(),

                      const SizedBox(height: 14),

                      // ================== RINGKASAN PESANAN ==================
                      _buildOrderSummaryCard(cart),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // ================== TOTAL + SLIDER ==================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOTAL (sementara pakai harga produk pertama)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6F7A74),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Rp ${_formatPrice(product.price)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // SLIDER
                      _buildSwipeSlider(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ================== WIDGET: ALAMAT ==================
  Widget _buildAddressCard() {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addr = addressProvider.address;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.place_outlined,
            color: primaryColor,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alamat Pengiriman',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${addr.name}\n${addr.address}\n${addr.city}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4F5A5E),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Telp: ${addr.phone}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6F7A74),
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditAddressPage(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primaryColor.withOpacity(0.5)),
              ),
              child: const Text(
                'Ubah',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // ================== BOTTOM SHEET: DAFTAR PRODUK ==================
  void _showCartItemsBottomSheet() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada produk di keranjang.'),
          backgroundColor: primaryColor,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const Text(
                  'Semua barang yang dipesan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 12,
                      color: Color(0xFFE3ECF4),
                    ),
                    itemBuilder: (ctx, index) {
                      final p = cart.items[index];
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              p.imagePath,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Rp ${_formatPrice(p.price)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF6F7A74),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'x1', // TODO: ganti dengan quantity dari cart kalau sudah ada
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================== WIDGET: PENGIRIMAN ==================
  Widget _buildShippingCard() {
    final methods = [
      'JNE - Reguler (2–4 hari kerja)',
      'J&T Express (1–3 hari kerja)',
      'GoSend - Instant (1 jam)',
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pengiriman',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < methods.length; i++)
            Column(
              children: [
                RadioListTile<int>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: i,
                  groupValue: _selectedShipping,
                  activeColor: primaryColor,
                  title: Text(
                    methods[i],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF243036),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _selectedShipping = val ?? 0;
                    });
                  },
                ),
                if (i != methods.length - 1)
                  const Divider(
                    height: 8,
                    color: Color(0xFFE3ECF4),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // ================== WIDGET: PEMBAYARAN ==================
  Widget _buildPaymentCard() {
    // urutan label harus sama dengan paymentIcons
    final methods = [
      'PayLater',
      'DANA',
      'Bayar di Tempat (COD)',
      'OVO',
      'Transfer Bank (ATM / m-Banking)', // indeks terakhir = transfer bank
    ];
    final int transferBankIndex = methods.length - 1;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 8),

          // LIST METODE PEMBAYARAN
          for (int i = 0; i < methods.length; i++)
            Column(
              children: [
                RadioListTile<int>(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  value: i,
                  groupValue: _selectedPayment,
                  activeColor: primaryColor,
                  title: Row(
                    children: [
                      if (i < paymentIcons.length)
                        Image.asset(
                          paymentIcons[i],
                          width: 24,
                          height: 24,
                        ),
                      if (i < paymentIcons.length)
                        const SizedBox(width: 8),
                      Text(
                        methods[i],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF243036),
                        ),
                      ),
                    ],
                  ),
                  onChanged: (val) {
                    setState(() {
                      _selectedPayment = val ?? 0;

                      // kalau pilih transfer bank dan belum ada bank terpilih, default ke BCA (index 0)
                      if (_selectedPayment == transferBankIndex &&
                          _selectedBank == null) {
                        _selectedBank = 0;
                      }
                    });
                  },
                ),
                if (i != methods.length - 1)
                  const Divider(
                    height: 8,
                    color: Color(0xFFE3ECF4),
                  ),
              ],
            ),

          // jika metode pembayaran = Transfer Bank, tampilkan pilihan bank
          if (_selectedPayment == transferBankIndex) _buildBankOptions(),
        ],
      ),
    );
  }

  // PILIHAN BANK SAAT TRANSFER BANK
  Widget _buildBankOptions() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pilih Bank',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < bankNames.length; i++)
            RadioListTile<int>(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 8.0),
              value: i,
              groupValue: _selectedBank,
              activeColor: primaryColor,
              title: Row(
                children: [
                  if (i < bankIcons.length)
                    Image.asset(
                      bankIcons[i],
                      width: 24,
                      height: 24,
                    ),
                  if (i < bankIcons.length) const SizedBox(width: 8),
                  Text(
                    bankNames[i],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF243036),
                    ),
                  ),
                ],
              ),
              onChanged: (val) {
                setState(() {
                  _selectedBank = val;
                });
              },
            ),
        ],
      ),
    );
  }

  // ================== WIDGET: RINGKASAN ==================
  Widget _buildOrderSummaryCard(CartProvider cart) {
    final items = cart.items;
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: const Text(
          'Ringkasan Pesanan',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: primaryColor,
          ),
        ),
      );
    }

    final int visibleCount = items.length > 3 ? 3 : items.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER seperti "Toko Penjual" + icon toko
          Row(
            children: const [
              Icon(
                Icons.storefront_rounded,
                color: primaryColor,
                size: 20,
              ),
              SizedBox(width: 6),
              Text(
                'Ringkasan Pesanan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // LIST MAKSIMAL 3 PRODUK
          for (int i = 0; i < visibleCount; i++) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      items[i].imagePath,
                      width: 46,
                      height: 46,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[i].name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Harga: Rp ${_formatPrice(items[i].price)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6F7A74),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'x1',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            if (i != visibleCount - 1) const SizedBox(height: 8),
          ],

          // TOMBOL LIHAT SEMUA (JIKA PRODUK > 3)
          if (items.length > 3) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: _showCartItemsBottomSheet,
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Lihat semua barang yang dipesan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ================== WIDGET: SLIDER ==================
  Widget _buildSwipeSlider() {
    const double thumbSize = 42;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final double maxThumbX = maxWidth - thumbSize;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              // mulai drag
              onHorizontalDragStart: (_) {
                setState(() {
                  _isSliding = true;
                });
              },
              // saat drag
              onHorizontalDragUpdate: (details) {
                final currentX = _sliderValue * maxThumbX;
                final newX =
                    (currentX + details.delta.dx).clamp(0.0, maxThumbX);

                setState(() {
                  _sliderValue =
                      maxThumbX == 0 ? 0.0 : newX / maxThumbX; // 0..1
                });
              },
              // lepas drag
              onHorizontalDragEnd: (_) {
                setState(() {
                  _isSliding = false;
                });

                // WAJIB hampir mentok baru dianggap konfirmasi
                if (_sliderValue >= 0.97) {
                  setState(() {
                    _sliderValue = 1.0;
                  });
                  _handleConfirmPayment();
                } else {
                  // kalau belum sampai ujung → balik lagi ke awal
                  setState(() {
                    _sliderValue = 0.0;
                  });
                }
              },
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3ECF4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Stack(
                  children: [
                    // TEKS DI TENGAH
                    Center(
                      child: Text(
                        _sliderValue >= 0.97
                            ? 'Lepas untuk konfirmasi'
                            : 'Swipe untuk melanjutkan',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                    ),

                    // THUMB
                    Positioned(
                      left: _sliderValue * maxThumbX,
                      top: 3,
                      bottom: 3,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        width: thumbSize,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _isSliding
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dengan men-swipe "Konfirmasi Pesanan", Anda menyetujui syarat dan ketentuan yang berlaku.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6F7A74),
              ),
            ),
          ],
        );
      },
    );
  }

  // ================== UTIL ==================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.withOpacity(0.18)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  String _formatPrice(num price) {
    final val = price.round();
    final s = val.toString();
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
}
