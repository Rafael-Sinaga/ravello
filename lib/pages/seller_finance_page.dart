import 'package:flutter/material.dart';

class SellerFinancePage extends StatelessWidget {
  const SellerFinancePage({super.key});

  static const Color primaryColor = Color(0xFF124170);
  static const Color backgroundColor = Color(0xFFF8FBFD);

  @override
  Widget build(BuildContext context) {
    // Dummy data riwayat transaksi
    final List<_FinanceTransaction> transactions = [
      _FinanceTransaction(
        title: 'Pembayaran oleh pembeli1',
        amountText: '+Rp4.516.500',
        isIncome: true,
      ),
      _FinanceTransaction(
        title: 'Pembayaran oleh pembeli2',
        amountText: '+Rp10.000.000',
        isIncome: true,
      ),
      _FinanceTransaction(
        title: 'Pembayaran oleh Ravello',
        amountText: '-Rp2.000.000',
        isIncome: false,
      ),
      _FinanceTransaction(
        title: 'Pembayaran oleh pembeli3',
        amountText: '+Rp8.000.000',
        isIncome: true,
      ),
      _FinanceTransaction(
        title: 'Pembayaran oleh pembeli4',
        amountText: '+Rp4.000.000',
        isIncome: true,
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Keuangan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: primaryColor,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== Kartu Total Saldo ======
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Total Saldo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6F7A74),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Rp24.516.500',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ====== Riwayat Transaksi ======
          const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 12),

          ...transactions.map(
            (tx) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTransactionCard(tx),
            ),
          ),

          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Sudah menampilkan semua Transaksi.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF6F7A74),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ====== Card satuan transaksi ======
  static Widget _buildTransactionCard(_FinanceTransaction tx) {
    final Color amountColor =
        tx.isIncome ? const Color(0xFF2E7D32) : const Color(0xFFD32F2F);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        title: Text(
          tx.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tx.amountText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF6F7A74),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== Model sederhana untuk transaksi keuangan ======
class _FinanceTransaction {
  final String title;
  final String amountText;
  final bool isIncome;

  _FinanceTransaction({
    required this.title,
    required this.amountText,
    required this.isIncome,
  });
}
