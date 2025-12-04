import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  static const Duration _timeoutDuration = Duration(seconds: 10);
  static UserModel? currentUser;
  static String? token;

  /// 🔑 LOGIN
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;

        // beberapa backend bungkus di "data"
        final dynamic rootDynamic = body['data'] ?? body;
        final Map<String, dynamic> root =
            (rootDynamic is Map<String, dynamic>) ? rootDynamic : body;

        // 🎯 coba ambil token dari beberapa field umum
        final String? parsedToken =
            (root['token'] ??
                    body['token'] ??
                    root['access_token'] ??
                    body['access_token'])
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
        final dynamic userJsonDynamic =
            root['user'] ?? body['user'] ?? root;
        final Map<String, dynamic> userJson =
            (userJsonDynamic is Map<String, dynamic>)
                ? userJsonDynamic
                : <String, dynamic>{};

        final dynamic idRaw =
            userJson['client_id'] ??
            userJson['id'] ??
            root['client_id'] ??
            root['id'] ??
            0;
        final dynamic nameRaw =
            userJson['name'] ?? root['name'] ?? body['name'] ?? '';
        final dynamic mailRaw =
            userJson['email'] ?? root['email'] ?? body['email'] ?? '';

        // 🎯 isSeller murni dari backend
        final bool isSellerFlag =
            (userJson['isSeller'] ??
                        root['isSeller'] ??
                        body['isSeller'] ??
                        false) ==
                    true;

        currentUser = UserModel(
          id: int.tryParse(idRaw.toString()) ?? 0,
          name: nameRaw.toString(),
          email: mailRaw.toString(),
          isSeller: isSellerFlag,
        );

        final prefs = await SharedPreferences.getInstance();

        print('User login : ${currentUser?.name} | ${currentUser?.email}');
        print('Token JWT  : $token');
        print('isSeller   : ${currentUser?.isSeller}');

        // simpan ke SharedPreferences (mirror dari backend)
        await prefs.setString('auth_token', token!);
        await prefs.setString('current_user_name', currentUser?.name ?? '');
        await prefs.setString('current_user_email', currentUser?.email ?? '');
        await prefs.setInt('current_user_id', currentUser?.id ?? 0);
        await prefs.setBool('isSeller', currentUser!.isSeller);

        return {'success': true, 'data': body};
      } else {
        return {
          'success': false,
          'message': 'Login gagal (${response.statusCode}): ${response.body}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// 📝 REGISTER
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

  /// 📩 KIRIM OTP (berdasarkan email)
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

  /// ✅ VERIFIKASI OTP (email + kode OTP)
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
      if (prefs.containsKey('profile_image_path')) {
        await prefs.remove('profile_image_path');
      }

      currentUser = null;
      token = null;

      print('AuthService: logout sukses — data user dihapus.');
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

    if (currentUser != null) {
      currentUser!.isSeller = status;
    }

    print('AuthService.setSellerStatus: $status');
  }

  /// ✅ Ambil seller status (untuk tombol "Daftar penjual / Lihat toko")
  static Future<bool> getSellerStatus() async {
    // 1️⃣ Sumber utama: currentUser (diisi dari backend saat login / update)
    if (currentUser != null) {
      return currentUser!.isSeller;
    }

    // 2️⃣ Fallback: nilai terakhir yang pernah disimpan (mis. sebelum currentUser terisi)
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getBool('isSeller') ?? false;
      return stored;
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
}
