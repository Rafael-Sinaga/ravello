// lib/services/order_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../services/auth_service.dart';
import '../models/order_model.dart';

class OrderService {
  static const Duration _timeout = Duration(seconds: 12);

  /// Buyer membuat order
  static Future<Map<String, dynamic>> createOrder({
    required int productId,
    required int quantity,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders'); // sesuaikan jika endpoint lain

    try {
      final res = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'product_id': productId,
              'quantity': quantity,
            }),
          )
          .timeout(_timeout);

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (e) {
        decoded = res.body;
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        BackendOrder? order;
        if (decoded is Map<String, dynamic>) {
          final obj = decoded['data'] ?? decoded['order'] ?? decoded;
          if (obj is Map<String, dynamic>) {
            order = BackendOrder.fromJson(obj);
          }
        }
        return {
          'success': true,
          'raw': decoded,
          'order': order,
        };
      } else {
        return {
          'success': false,
          'message': (decoded is Map && decoded['message'] != null)
              ? decoded['message']
              : 'Gagal membuat order (HTTP ${res.statusCode})',
          'raw': decoded,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// Fetch orders berdasarkan role (seller / buyer)
  static Future<List<BackendOrder>> fetchOrders({
    required String role, // 'seller' atau 'buyer'
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
        // bukan JSON -> kembalikan kosong
        debugPrint('OrderService.fetchOrders JSON decode error: $e');
        return <BackendOrder>[];
      }

      // normalize ke List<dynamic>
      List<dynamic> list = [];

      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map<String, dynamic>) {
        if (decoded['data'] is List) {
          list = decoded['data'] as List<dynamic>;
        } else if (decoded['orders'] is List) {
          list = decoded['orders'] as List<dynamic>;
        } else {
          // mungkin backend mengembalikan objek tunggal (order) di 'data' atau 'order'
          Map<String, dynamic>? candidate;
          if (decoded['data'] is Map<String, dynamic>) {
            candidate = decoded['data'] as Map<String, dynamic>?;
          } else if (decoded['order'] is Map<String, dynamic>) {
            candidate = decoded['order'] as Map<String, dynamic>?;
          } else if (decoded['data'] is Map) {
            candidate = Map<String, dynamic>.from(decoded['data']);
          } else if (decoded['order'] is Map) {
            candidate = Map<String, dynamic>.from(decoded['order']);
          }

          if (candidate != null) {
            list = [candidate];
          } else {
            // kadang server bungkus data: { data: { order: {...} } }
            try {
              final inner = decoded['data'];
              if (inner is Map && inner['order'] is Map) {
                list = [Map<String, dynamic>.from(inner['order'])];
              }
            } catch (_) {
              // ignore
            }
          }
        }
      }

      // parse menjadi BackendOrder
      final parsed = list
          .whereType<Map<String, dynamic>>()
          .map((j) => BackendOrder.fromJson(j))
          .toList();

      return parsed;
    } catch (e) {
      debugPrint('OrderService.fetchOrders error: $e');
      return <BackendOrder>[];
    }
  }

  /// Update status order (seller)
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String newStatus, // e.g. 'diproses','dikirim','selesai'
    String? tracking,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status'); // sesuaikan jika beda

    try {
      final body = {'status': newStatus, if (tracking != null) 'tracking': tracking};
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
      } else {
        return {
          'success': false,
          'message': (decoded is Map && decoded['message'] != null)
              ? decoded['message']
              : 'Gagal update status (HTTP ${res.statusCode})',
          'raw': decoded,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }
}
