// lib/services/order_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../services/auth_service.dart';
import '../models/order_model.dart';

class OrderService {
  static const Duration _timeout = Duration(seconds: 12);

  /// ==========================
  /// BUYER CREATE ORDER
  /// ==========================
/// Buyer membuat order (SESUAI BACKEND BARU)
static Future<Map<String, dynamic>> createOrder({
  required List<Map<String, dynamic>> orderItems,
  required String paymentMethod,
  String? shippingAddress,
}) async {
  final token = await AuthService.getToken();
  final url = Uri.parse('${ApiConfig.baseUrl}/order');


  try {
    final body = {
      "payment_method": paymentMethod,
      "shipping_address": shippingAddress,
      "orderItems": orderItems
    };

    print("ORDER BODY => $body");

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ).timeout(_timeout);

    print("ORDER STATUS => ${res.statusCode}");
    print("ORDER BODY => ${res.body}");

    dynamic decoded;
    try {
      decoded = jsonDecode(res.body);
    } catch (e) {
      decoded = res.body;
    }

    if (res.statusCode == 200 || res.statusCode == 201) {
      return {
        'success': true,
        'raw': decoded,
      };
    } else {
      return {
        'success': false,
        'message': decoded['message'] ?? 'Gagal membuat order',
        'raw': decoded,
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Kesalahan koneksi: $e'};
  }
}

  /// ==========================
  /// FETCH ORDER
  /// ==========================
  static Future<List<BackendOrder>> fetchOrders({
    required String role,
    int? userId,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/orders?role=$role${userId != null ? '&user_id=$userId' : ''}',
    );

    try {
      final res = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(_timeout);

      if (res.statusCode != 200) return <BackendOrder>[];

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (e) {
        debugPrint('OrderService.fetchOrders JSON decode error: $e');
        return <BackendOrder>[];
      }

      List<dynamic> list = [];

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is List) {
          list = decoded['data'];
        } else if (decoded['orders'] is List) {
          list = decoded['orders'];
        }
      }

      return list
          .whereType<Map<String, dynamic>>()
          .map((j) => BackendOrder.fromJson(j))
          .toList();

    } catch (e) {
      debugPrint('OrderService.fetchOrders error: $e');
      return <BackendOrder>[];
    }
  }

  /// ==========================
  /// UPDATE STATUS (SELLER)
  /// ==========================
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? tracking,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status');

    try {
      final body = {
        'status': newStatus,
        if (tracking != null) 'tracking': tracking
      };

      final res = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (e) {
        decoded = res.body;
      }

      if (res.statusCode == 200) {
        return {'success': true, 'raw': decoded};
      }

      return {
        'success': false,
        'message': (decoded is Map && decoded['message'] != null)
            ? decoded['message']
            : 'Gagal update status (HTTP ${res.statusCode})',
        'raw': decoded,
      };

    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan koneksi: $e'
      };
    }
  }
}
