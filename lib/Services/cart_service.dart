import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../utils/api_config.dart';

class CartService {

  static const Duration _timeout = Duration(seconds: 15);

  /// ==========================
  /// 1️⃣ TAMBAH KE KERANJANG
  /// POST /cart
  /// ==========================
 static Future<Map<String, dynamic>> addToCart(int productId) async {
  try {
    final token = await AuthService.getToken();

    // DEBUG
    print("ADD CART TOKEN => $token");
    print("PRODUCT ID => $productId");

    if (token == null || token.isEmpty) {
      return {
        'success': false,
        'message': 'Token kosong, silakan login ulang'
      };
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/cart');

final res = await http.post(
  url,
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  },
  body: jsonEncode({
    'product_id': productId
  }),
).timeout(_timeout);

// 🔥 DEBUG LOG
print('CART URL => $url');
print('TOKEN => $token');
print('PRODUCT ID => $productId');
print('STATUS CODE => ${res.statusCode}');
print('BODY => ${res.body}');


    print("CART STATUS => ${res.statusCode}");
    print("CART BODY => ${res.body}");

    return jsonDecode(res.body);

  } catch (e) {
    print("ADD CART ERROR => $e");
    return {
      'success': false,
      'message': 'Gagal tambah ke cart',
      'error': e.toString()
    };
  }
}


  /// ==========================
  /// 2️⃣ GET CART
  /// GET /cart
  /// ==========================
  static Future<List<dynamic>> getCart() async {
    try {
      final token = await AuthService.getToken();

      final url = Uri.parse('${ApiConfig.baseUrl}/cart');

      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token'
        },
      ).timeout(_timeout);

      return jsonDecode(res.body);

    } catch (e) {
      return [];
    }
  }

  /// ==========================
  /// 3️⃣ DELETE ITEM
  /// DELETE /cart/:cart_id
  /// ==========================
  static Future<Map<String, dynamic>> deleteItem(int cartId) async {
    try {
      final token = await AuthService.getToken();

      final url = Uri.parse('${ApiConfig.baseUrl}/cart/$cartId');

      final res = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token'
        },
      ).timeout(_timeout);

      return jsonDecode(res.body);

    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal hapus item',
        'error': e.toString()
      };
    }
  }

  /// ==========================
  /// 4️⃣ SUMMARY CART
  /// GET /cart/summary
  /// ==========================
  static Future<Map<String, dynamic>> getSummary() async {
    try {
      final token = await AuthService.getToken();

      final url = Uri.parse('${ApiConfig.baseUrl}/cart/summary');

      final res = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token'
        },
      ).timeout(_timeout);

      return jsonDecode(res.body);

    } catch (e) {
      return {
        'total_harga': 0,
        'total_quantity': 0
      };
    }
  }

  /// ==========================
  /// 5️⃣ CLEAR CART (OPSIONAL)
  /// ==========================
  static Future clearCart(List<int> cartIds) async {
    for (int id in cartIds) {
      await deleteItem(id);
    }
  }
}