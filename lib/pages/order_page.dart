// lib/pages/order_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../models/product_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _status = 'Diproses';
  int _remainingSeconds = 60; // 1 menit per proses
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _nextStatus();
      }
    });
  }

  void _nextStatus() {
    if (_status == 'Diproses') {
      setState(() {
        _status = 'Sedang dikirim';
        _remainingSeconds = 60;
      });
    } else if (_status == 'Sedang dikirim') {
      setState(() {
        _status = 'Selesai';
        _timer?.cancel();
      });
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<OrderProvider>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF124170),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF124170)),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      backgroundColor: const Color(0xFFF8FBFD),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pesanan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontFamily: 'Poppins',
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final Product order = orders[index];
                final bool isActiveOrder = index == 0;

                // Jika pesanan pertama, gunakan status dan waktu dinamis
                final String status = isActiveOrder ? _status : 'Selesai';
                final Color statusColor = status == 'Selesai'
                    ? Colors.green
                    : status == 'Sedang dikirim'
                        ? Colors.orange
                        : Colors.blue;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        order.imagePath,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      order.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF124170),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (isActiveOrder && status != 'Selesai') ...[
                          const SizedBox(height: 2),
                          Text(
                            'Waktu tersisa: ${_formatTime(_remainingSeconds)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6F7D8D),
                            ),
                          ),
                        ],
                        const SizedBox(height: 2),
                        const Text(
                          '2 November 2025',
                          style: TextStyle(
                            color: Color(0xFF6F7D8D),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      'Rp${order.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF124170),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
