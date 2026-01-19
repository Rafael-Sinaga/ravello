// lib/services/auth_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const Duration _timeoutDuration = Duration(seconds: 10);
  static UserModel? currentUser;
  static String? token;

  /// 🔑 LOGIN (fix: remove undefined userJson reference)
static Future<Map<String, dynamic>> login(
  String email,
  String password,
) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

  try {
    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeoutDuration);

    print('LOGIN status: ${response.statusCode}');
    print('LOGIN body  : ${response.body}');

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Login gagal (${response.statusCode})',
      };
    }

    final Map<String, dynamic> root =
        jsonDecode(response.body) as Map<String, dynamic>;

    // ======================
    // TOKEN
    // ======================
    final String? parsedToken = root['token']?.toString();
    if (parsedToken == null || parsedToken.isEmpty) {
      return {
        'success': false,
        'message': 'Token tidak ditemukan.',
      };
    }
    token = parsedToken;

    // ======================
    // USER OBJECT
    // ======================
    final Map<String, dynamic> userObj =
        (root['user'] ?? root['client'] ?? root['data'] ?? root)
            as Map<String, dynamic>;

    final id = int.tryParse(
            (userObj['client_id'] ?? root['client_id']).toString()) ??
        0;

    final name = (userObj['name'] ?? root['name'] ?? '').toString();
    final emailUser =
        (userObj['email'] ?? root['email'] ?? '').toString();

    // ======================
    // STORE DETECTION (FIX)
    // ======================
    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    int? storeId;

    final dynamic storeObj = userObj['store_id'] ?? root['store_id'];
    if (storeObj is Map<String, dynamic>) {
      storeId = _asInt(storeObj['store_id'] ?? storeObj['store_id']);
    }

    storeId = _asInt(root['store_id']);

    print('LOGIN STORE ID => $storeId');

    final bool hasStore = storeId != null;

    // ======================
    // ROLE
    // ======================
    final role =
        (userObj['role'] ?? root['role'])?.toString().toLowerCase();
    final bool isSellerFromRole = role == 'seller';

    // 🔥 FINAL SELLER STATUS
    final bool isSeller = hasStore || isSellerFromRole;

    print('''
LOGIN DEBUG
role      => $role
storeId   => $storeId
hasStore  => $hasStore
SELLER    => $isSeller
''');

    // ======================
    // SAVE PREFS
    // ======================
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', token!);
    await prefs.setInt('current_user_id', id);
    await prefs.setString('current_user_name', name);
    await prefs.setString('current_user_email', emailUser);

    await prefs.setBool('isSeller', isSeller);
    await prefs.setBool('isSeller_local', isSeller);

    if (storeId != null) {
      print('LOGIN: storeId ditemukan = $storeId');

      await prefs.setInt('store_id', storeId);

      try {
        final r = await getStoreProfile();
        print('REFRESH STORE AFTER LOGIN => $r');
      } catch (e) {
        print('ERROR getStoreProfile: $e');
      }
    }


    // ======================
    // MEMORY
    // ======================
    currentUser = UserModel(
      id: id,
      name: name,
      email: emailUser,
      isSeller: isSeller,
    );

    return {'success': true, 'data': root};
  } catch (e) {
    return {
      'success': false,
      'message': 'Kesalahan koneksi: $e',
    };
  }
}



  /// 📝 REGISTER
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/postClient');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
            }),
          )
          .timeout(_timeoutDuration);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['user'] != null) {
          currentUser = UserModel.fromJson(data['user']);
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message':
              'Registrasi gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }
static Future<Map<String, dynamic>> resetPassword(String email, String newPassword) async {
  final url = Uri.parse('${ApiConfig.baseUrl}/auth/reset-password');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': newPassword,
      }),
    ).timeout(_timeoutDuration);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': data['message'] ?? 'Gagal reset password'
      };
    }
  } catch (e) {
    return {'success': false, 'message': 'Kesalahan koneksi: $e'};
  }
}

   /// 📩 KIRIM / REQUEST OTP
  static Future<Map<String, dynamic>> sendOtp(
    String email, {
    required String actionFlow,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'action_flow': actionFlow,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan koneksi: $e',
      };
    }
  }

  /// ✅ VERIFIKASI OTP (email + otp + action_flow)
  static Future<Map<String, dynamic>> verifyOtp(
    String email,
    String otp, {
    required String actionFlow,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/verify-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
              'action_flow': actionFlow,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP salah atau kadaluarsa',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Kesalahan koneksi: $e',
      };
    }
  }





  /// 🚪 LOGOUT
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey('current_user_name')) {
        await prefs.remove('current_user_name');
      }
      if (prefs.containsKey('current_user_email')) {
        await prefs.remove('current_user_email');
      }
      if (prefs.containsKey('current_user_id')) {
        await prefs.remove('current_user_id');
      }
      if (prefs.containsKey('auth_token')) {
        await prefs.remove('auth_token');
      }
      if (prefs.containsKey('isSeller')) {
        await prefs.remove('isSeller');
      }
      if (prefs.containsKey('isSeller_local')) {
        await prefs.remove('isSeller_local');
      }
      if (prefs.containsKey('profile_image_path')) {
        await prefs.remove('profile_image_path');
      }
      if (prefs.containsKey('store_id')) {
        await prefs.remove('store_id');
      }
      if (prefs.containsKey('storeName')) {
        await prefs.remove('storeName');
      }
      if (prefs.containsKey('storeDescription')) {
        await prefs.remove('storeDescription');
      }
      if (prefs.containsKey('storeImagePath')) {
        await prefs.remove('storeImagePath');
      }


      // 🧹 PENTING: hapus storeId & data boost supaya tidak kebawa ke akun lain
      if (prefs.containsKey('store_id')) {
        await prefs.remove('store_id');
      }
      if (prefs.containsKey('boosted_product_ids')) {
        await prefs.remove('boosted_product_ids');
      }

      currentUser = null;
      token = null;

      print('AuthService: logout sukses — data user & store dihapus.');
    } catch (e) {
      print('AuthService.logout error: $e');
      currentUser = null;
      token = null;
    }
  }

  /// 🔐 Ambil token dari memori / SharedPreferences
  static Future<String?> getToken() async {
    if (token != null && token!.isNotEmpty) {
      return token;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('auth_token');

      if (stored != null && stored.isNotEmpty) {
        token = stored;
        return token;
      }
      return null;
    } catch (e) {
      print('AuthService.getToken error: $e');
      return null;
    }
  }

  /// ✅ Set seller status (dipanggil setelah daftar penjual & backend sukses update)
  static Future<void> setSellerStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isSeller', status);
    await prefs.setBool('isSeller_local', status);

    if (currentUser != null) {
      currentUser!.isSeller = status;
    }

    print('AuthService.setSellerStatus: $status');
  }

  /// ✅ Ambil seller status (untuk tombol "Daftar penjual / Lihat toko")
  static Future<bool> getSellerStatus() async {
    if (currentUser != null) {
      return currentUser!.isSeller;
    }

    final prefs = await SharedPreferences.getInstance();

    final bool? stored = prefs.getBool('isSeller');
    final bool? local = prefs.getBool('isSeller_local');
    final int? storeId = prefs.getInt('store_id');

    final bool hasStore = storeId != null && storeId > 0;

    final bool result = hasStore || stored == true || local == true;

    print('''
SELLER STATUS DEBUG
stored=$stored
local=$local
storeId=$storeId
hasStore=$hasStore
RESULT=$result
''');

    return result;
  }


  /// 📸 Simpan path foto profil
  static Future<void> setProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  /// 📸 Ambil path foto profil (nullable)
  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }

// di dalam class AuthService

/// di AuthService
static Future<Map<String, dynamic>> getStoreProfile() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final int? storeId = prefs.getInt('store_id');

    if (storeId == null) {
      return {
        'success': false,
        'message': 'storeId tidak ditemukan di local storage'
      };
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/store/profile');

    final response = await http.get(url).timeout(_timeoutDuration);

    print("STORE API STATUS => ${response.statusCode}");
    print("STORE API BODY   => ${response.body}");

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Gagal ambil toko (${response.statusCode})'
      };
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;

    if (body['success'] != true) {
      return {
        'success': false,
        'message': body['message'] ?? 'Response invalid'
      };
    }

    final Map<String, dynamic> data =
        body['data'] as Map<String, dynamic>;

    // 🔥 SESUAI BACKEND (snake_case)
    final String? storeName = data['store_name'];
    final String? description = data['description'];

    // simpan cache
    if (storeName != null) {
      await prefs.setString('storeName', storeName);
    }
    if (description != null) {
      await prefs.setString('storeDescription', description);
    }

    return {
      'success': true,
      'data': {
        'store_name': storeName,
        'description': description,
      }
    };
  } catch (e) {
    print("STORE API ERROR => $e");
    return {'success': false, 'message': 'Kesalahan koneksi: $e'};
  }
}
}