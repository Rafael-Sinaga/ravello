// lib/services/auth_service.dart
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  // default timeout used by other calls (keep original)
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // slightly longer timeout specifically for login to reduce false timeouts
  static const Duration _loginTimeout = Duration(seconds: 15);

  static UserModel? currentUser;
  static String? token;

  /// helper: cek koneksi internet (via connectivity_plus)
  static Future<bool> _hasNetwork() async {
    try {
      final conn = await Connectivity().checkConnectivity();
      return conn != ConnectivityResult.none;
    } catch (e) {
      // jika check gagal, anggap tidak ada koneksi
      print('Connectivity check failed: $e');
      return false;
    }
  }

  /// helper: post with retry + exponential backoff (used for login)
  static Future<http.Response> _postWithRetry(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    int maxAttempts = 3,
    Duration timeout = _loginTimeout,
  }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final response = await http
            .post(url, headers: headers, body: body)
            .timeout(timeout);
        return response;
      } on TimeoutException catch (e) {
        print('POST attempt $attempt timed out: $e');
        if (attempt >= maxAttempts) rethrow;
      } on SocketException catch (e) {
        print('POST attempt $attempt socket error: $e');
        if (attempt >= maxAttempts) rethrow;
      } catch (e) {
        print('POST attempt $attempt failed: $e');
        // non-network errors: break after max attempts
        if (attempt >= maxAttempts) rethrow;
      }

      // exponential backoff: 500ms, 1000ms, 2000ms...
      await Future.delayed(Duration(milliseconds: 500 * (1 << (attempt - 1))));
    }
  }

  /// 🔑 LOGIN (ditingkatkan: cek koneksi, retry, timeout lebih lebar)
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/auth/login');

    // cek koneksi dulu
    final hasNet = await _hasNetwork();
    if (!hasNet) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet. Periksa jaringanmu.'
      };
    }

    try {
      // gunakan wrapper dengan retry + timeout agar lebih tahan banting
      final response = await _postWithRetry(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
        maxAttempts: 3,
        timeout: _loginTimeout,
      );

      print('LOGIN status: ${response.statusCode}');
      print('LOGIN body  : ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;

        // beberapa backend bungkus di "data"
        final dynamic rootDynamic = body['data'] ?? body;
        final Map<String, dynamic> root =
            (rootDynamic is Map<String, dynamic>) ? rootDynamic : body;

        // 🎯 coba ambil token dari beberapa field umum
        final String? parsedToken =
            (root['token'] ?? body['token'] ?? root['access_token'] ?? body['access_token'])
                ?.toString();

        if (parsedToken == null || parsedToken.isEmpty) {
          print('LOGIN ERROR: token tidak ditemukan di response.');
          return {
            'success': false,
            'message':
                'Login berhasil tapi token tidak ditemukan di response server.'
          };
        }

        token = parsedToken;

        // ambil data user
        final dynamic userJsonDynamic = root['user'] ?? body['user'] ?? root;
        final Map<String, dynamic> userJson =
            (userJsonDynamic is Map<String, dynamic>)
                ? userJsonDynamic
                : <String, dynamic>{};

        final dynamic idRaw =
            userJson['client_id'] ?? userJson['id'] ?? root['client_id'] ?? root['id'] ?? 0;
        final dynamic nameRaw =
            userJson['name'] ?? root['name'] ?? body['name'] ?? '';
        final dynamic mailRaw =
            userJson['email'] ?? root['email'] ?? body['email'] ?? '';

        // 🎯 isSeller dari backend (bisa saja belum akurat)
        final bool backendSeller =
            (userJson['isSeller'] ?? root['isSeller'] ?? body['isSeller'] ?? false) == true;

        final prefs = await SharedPreferences.getInstance();

        // 🔁 baca status lokal lama (mis: user sudah punya toko, tapi backend belum update flag)
        final bool localSeller =
            prefs.getBool('isSeller') ?? prefs.getBool('isSeller_local') ?? false;

        // 🔁 kalau user sudah punya storeId, anggap seller
        final int? storedStoreId = prefs.getInt('storeId');
        final bool hasStore = storedStoreId != null && storedStoreId > 0;

        // ✅ status final = backend OR lokal OR punya toko
        final bool effectiveSeller = backendSeller || localSeller || hasStore;

        // buat user model pakai status final
        currentUser = UserModel(
          id: int.tryParse(idRaw.toString()) ?? 0,
          name: nameRaw.toString(),
          email: mailRaw.toString(),
          isSeller: effectiveSeller,
        );

        print('User login : ${currentUser?.name} | ${currentUser?.email}');
        print('Token JWT  : $token');
        print('isSeller   : backend=$backendSeller, local=$localSeller, hasStore=$hasStore, effective=$effectiveSeller');

        // simpan ke SharedPreferences (mirror dari status final)
        await prefs.setString('auth_token', token!);
        await prefs.setString('current_user_name', currentUser?.name ?? '');
        await prefs.setString('current_user_email', currentUser?.email ?? '');
        await prefs.setInt('current_user_id', currentUser?.id ?? 0);

        await prefs.setBool('isSeller', effectiveSeller);
        await prefs.setBool('isSeller_local', effectiveSeller);

        // 🔐 === HANDLE STORE / TOKO PER AKUN ===
        //
        // Cari store_id dari berbagai kemungkinan field:
        // - langsung di root / user
        // - atau di object "store"
        int? _asInt(dynamic v) {
          if (v == null) return null;
          if (v is int) return v;
          if (v is num) return v.toInt();
          return int.tryParse(v.toString());
        }

        int? storeId;
        final storeObj = userJson['store'] ?? root['store'];

        if (storeObj is Map<String, dynamic>) {
          storeId = _asInt(storeObj['store_id'] ?? storeObj['id']);
        }

        storeId ??= _asInt(userJson['store_id'] ?? root['store_id'] ?? body['store_id']);

        if (storeId != null) {
          print('LOGIN: storeId untuk user ini = $storeId');
          await prefs.setInt('storeId', storeId);
        } else {
          // user ini belum punya toko → jangan pakai storeId milik user sebelumnya
          print('LOGIN: user belum punya toko, hapus storeId lama (jika ada).');
          if (prefs.containsKey('storeId')) {
            await prefs.remove('storeId');
          }
        }

        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'message': 'Login gagal (${response.statusCode}): ${response.body}',
        };
      }
    } on TimeoutException catch (e) {
      print('LOGIN TimeoutException: $e');
      return {'success': false, 'message': 'Koneksi timeout: server terlalu lambat. Coba lagi.'};
    } on SocketException catch (e) {
      print('LOGIN SocketException: $e');
      return {'success': false, 'message': 'Tidak dapat terhubung ke server. Periksa koneksi internet.'};
    } catch (e) {
      print('LOGIN error: $e');
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// 📝 REGISTER (tetap seperti sebelumnya)
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
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

  /// 📩 KIRIM OTP (berdasarkan email) (tetap sama)
  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/send-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal mengirim OTP'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// ✅ VERIFIKASI OTP (email + kode OTP) (tetap sama)
  static Future<Map<String, dynamic>> verifyOtp(
      String email, String otp) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/postClient/verify-otp');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'otp': otp,
            }),
          )
          .timeout(_timeoutDuration);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'OTP salah atau kadaluarsa'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Kesalahan koneksi: $e'};
    }
  }

  /// 🚪 LOGOUT (tetap sama)
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

  /// 🔐 Ambil token dari memori / SharedPreferences (tetap sama)
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

  /// ✅ Ambil seller status (untuk tombol "Daftar penjual / Lihat toko") (tetap sama)
  static Future<bool> getSellerStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bool local =
          prefs.getBool('isSeller') ?? prefs.getBool('isSeller_local') ?? false;
      final bool memory = currentUser?.isSeller ?? false;

      final int? storedStoreId = prefs.getInt('storeId');
      final bool hasStore = storedStoreId != null && storedStoreId > 0;

      final bool result = local || memory || hasStore;

      // sinkronkan kembali ke currentUser bila sudah ada
      if (currentUser != null) {
        currentUser!.isSeller = result;
      }

      print('AuthService.getSellerStatus -> '
          'local=$local, memory=$memory, hasStore=$hasStore, result=$result');

      return result;
    } catch (e) {
      print('AuthService.getSellerStatus error: $e');
      return currentUser?.isSeller ?? false;
    }
  }

  /// 📸 Simpan path foto profil (tetap sama)
  static Future<void> setProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
  }

  /// 📸 Ambil path foto profil (nullable) (tetap sama)
  static Future<String?> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profile_image_path');
  }
}
