// lib/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'order_page.dart';
import '../widgets/navbar.dart';
import 'verify_seller_page.dart';
import 'onboarding.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = '';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        final Map<String, dynamic> data = jsonDecode(userJson);
        setState(() {
          userName = (data['name'] ?? data['fullname'] ?? '') as String;
          userEmail = (data['email'] ?? '') as String;
        });
      } else if (AuthService.currentUser != null) {
        setState(() {
          userName = AuthService.currentUser!.name;
          userEmail = AuthService.currentUser!.email;
        });
      }
    } catch (_) {
      // Abaikan error kecil, agar UI tetap jalan
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF124170);
    const Color lightBackground = Color(0xFFF8FBFD);

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 350),
            pageBuilder: (_, __, ___) => const HomePage(),
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: lightBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryColor),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 350),
                  pageBuilder: (_, __, ___) => const HomePage(),
                ),
              );
            },
          ),
          title: const Text('Profil', style: TextStyle(color: primaryColor)),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundImage: AssetImage('assets/images/profile.png'),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName.isEmpty ? 'Nama Pengguna' : userName,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail.isEmpty ? 'email@contoh.com' : userEmail,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF6F7A74)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            // Komponen profil lainnya tetap sama
            const SizedBox(height: 400),
          ]),
        ),
      ),
    );
  }
}
