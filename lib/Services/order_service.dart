// lib/services/order_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_config.dart';
import '../models/order_model.dart';
import '../services/auth_service.dart';

class OrderService {
  static const Duration _timeout = Duration(seconds: 10);

  /// =============================
  /// 📌 BUYER BUAT PESANAN
  /// =============================
  static Future<Map<String, dynamic>> createOrder({
    required int productId,
    required int quantity,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders');

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

      final body = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {
          'success': true,
          'data': body,
          'order': BackendOrder.fromJson(body),
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Gagal membuat pesanan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan koneksi: $e',
      };
    }
  }

  /// =============================
  /// 📌 SELLER UPDATE STATUS ORDER
  /// =============================
  static Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String newStatus,
  }) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status');

    try {
      final res = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'status': newStatus}),
          )
          .timeout(_timeout);

      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        return {
          'success': true,
          'data': body,
        };
      }

      return {
        'success': false,
        'message': body['message'] ?? 'Gagal update status',
      };
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// =============================
  /// 📌 BUYER / SELLER LOAD ORDER
  /// =============================
  static Future<List<BackendOrder>> fetchOrders(String role) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders?role=$role');

    try {
      final res = await http
          .get(
            url,
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(_timeout);

      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body);
      final List list = data is List ? data : (data['data'] ?? []);

      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => BackendOrder.fromJson(e))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
