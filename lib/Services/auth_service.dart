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
        'message': 'Login gagal (${response.statusCode}): ${response.body}',
      };
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> root = body;

    // ======================
    // TOKEN
    // ======================
    final String? parsedToken = root['token']?.toString();
    if (parsedToken == null || parsedToken.isEmpty) {
      return {
        'success': false,
        'message': 'Login berhasil tapi token tidak ditemukan di response.',
      };
    }
    token = parsedToken;

    // ======================
    // NORMALISASI USER OBJECT
    // ======================
    final Map<String, dynamic> userObj =
        (root['user'] is Map<String, dynamic>)
            ? Map<String, dynamic>.from(root['user'])
            : (root['client'] is Map<String, dynamic>)
                ? Map<String, dynamic>.from(root['client'])
                : (root['data'] is Map<String, dynamic>)
                    ? Map<String, dynamic>.from(root['data'])
                    : root;

    final dynamic idRaw =
        userObj['client_id'] ?? userObj['id'] ?? root['client_id'] ?? 0;
    final dynamic nameRaw = userObj['name'] ?? root['name'] ?? '';
    final dynamic mailRaw = userObj['email'] ?? root['email'] ?? '';

    // ======================
    // ROLE SELLER
    // ======================
    final dynamic rawRole = userObj['role'] ?? root['role'];
    final String? roleString =
        rawRole != null ? rawRole.toString().toLowerCase().trim() : null;
    final bool isSellerFromRole = roleString == 'seller';

    print('LOGIN ROLE DETECTED: $roleString (seller=$isSellerFromRole)');

    final prefs = await SharedPreferences.getInstance();

    // cek cache lama
    final bool prevLocal =
        prefs.getBool('isSeller') ?? prefs.getBool('isSeller_local') ?? false;
    final int? cachedStoreId = prefs.getInt('storeId');
    final bool hasStore = cachedStoreId != null && cachedStoreId > 0;

    final bool effectiveSeller = isSellerFromRole || prevLocal || hasStore;

    currentUser = UserModel(
      id: int.tryParse(idRaw.toString()) ?? 0,
      name: nameRaw.toString(),
      email: mailRaw.toString(),
      isSeller: effectiveSeller,
    );

    // simpan user ke prefs
    await prefs.setString('auth_token', token!);
    await prefs.setString('current_user_name', currentUser!.name);
    await prefs.setString('current_user_email', currentUser!.email);
    await prefs.setInt('current_user_id', currentUser!.id);
    await prefs.setBool('isSeller', effectiveSeller);
    await prefs.setBool('isSeller_local', effectiveSeller);

    // ======================
    // STORE HANDLING (PERBAIKAN BESAR)
    // ======================
    int? _asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    int? storeId;

    // cek userObj.store
    final dynamic storeObj = userObj['store'] ?? root['store'];
    if (storeObj is Map<String, dynamic>) {
      storeId = _asInt(storeObj['store_id'] ?? storeObj['id']);
    }

    // fallback ke field langsung
    storeId ??= _asInt(
      userObj['store_id'] ?? root['store_id'] ?? body['store_id'],
    );

    if (storeId != null) {
      print('LOGIN: storeId ditemukan = $storeId');
      await prefs.setInt('storeId', storeId);

      // langsung ambil profil toko → BIKIN UI SELALU TERUPDATE
      try {
        final r = await getStoreProfile();
        print('REFRESH STORE AFTER LOGIN → $r');
      } catch (e) {
        print('ERROR getStoreProfile setelah login: $e');
      }
    } else {
      // user tidak punya toko → bersihkan store lama dari akun sebelumnya
      print('LOGIN: tidak ada storeId → hapus sisa data toko lama.');
      await prefs.remove('storeId');
      await prefs.remove('storeName');
      await prefs.remove('storeDescription');
      await prefs.remove('storeImagePath');
    }

    return {'success': true, 'data': body};
  } catch (e) {
    return {'success': false, 'message': 'Kesalahan koneksi: $e'};
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
      if (prefs.containsKey('storeId')) {
        await prefs.remove('storeId');
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
      if (prefs.containsKey('storeId')) {
        await prefs.remove('storeId');
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
    // 1️⃣ dari memori dulu
    if (currentUser != null) {
      return currentUser!.isSeller;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final bool? stored = prefs.getBool('isSeller');
      final bool? local = prefs.getBool('isSeller_local');
      final int? storeId = prefs.getInt('storeId');

      final bool hasStore = storeId != null && storeId > 0;
      final bool result = (stored ?? local ?? false) || hasStore;

      print(
          'AuthService.getSellerStatus -> local=${stored ?? local}, memory=${currentUser?.isSeller}, hasStore=$hasStore, result=$result');

      return result;
    } catch (e) {
      print('AuthService.getSellerStatus error: $e');
      return false;
    }
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
    final int? storeId = prefs.getInt('storeId');
    if (storeId == null) {
      return {'success': false, 'message': 'storeId tidak ditemukan'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/store/$storeId');
    final response = await http.get(url).timeout(_timeoutDuration);

    if (response.statusCode != 200) {
      return {
        'success': false,
        'message': 'Gagal mengambil profil toko (${response.statusCode})'
      };
    }

    final Map<String, dynamic> body = jsonDecode(response.body) as Map<String, dynamic>;
    final Map<String, dynamic> data = (body['data'] ?? body) as Map<String, dynamic>;

    // Normalize keys: support snake_case dan camelCase
    String? storeName = data['storeName']?.toString()
        ?? data['store_name']?.toString()
        ?? data['store_name_translated']?.toString()
        ?? data['store_name_raw']?.toString();

    String? description = data['description']?.toString()
        ?? data['storeDescription']?.toString()
        ?? data['store_description']?.toString();

    String? imagePath = data['imagePath']?.toString()
        ?? data['image_path']?.toString()
        ?? data['storeImagePath']?.toString()
        ?? data['store_image_path']?.toString();

    // Write canonical keys to prefs
    if (storeName != null) await prefs.setString('storeName', storeName);
    if (description != null) await prefs.setString('storeDescription', description);
    if (imagePath != null) await prefs.setString('storeImagePath', imagePath);

    return {
      'success': true,
      'data': {
        'storeName': storeName,
        'description': description,
        'imagePath': imagePath,
      }
    };
  } catch (e) {
    print('AuthService.getStoreProfile error: $e');
    return {'success': false, 'message': 'Kesalahan koneksi: $e'};
  }
}





}
