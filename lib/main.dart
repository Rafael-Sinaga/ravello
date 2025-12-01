// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // untuk kDebugMode

// === Pages ===
import 'package:ravello/pages/splash_screen.dart';
import 'package:ravello/pages/login_page.dart';
import 'package:ravello/pages/register_page.dart';
import 'package:ravello/pages/home_page.dart';
import 'package:ravello/pages/cart_page.dart';
import 'package:ravello/pages/onboarding.dart';
import 'package:ravello/pages/checkout_page.dart';
import 'package:ravello/pages/profile_page.dart';
import 'package:ravello/pages/favorite_page.dart';
import 'package:ravello/pages/order_page.dart';

// ⭐ Seller-related pages
// ⬇️ SUSUN SUPAYA SAMA DENGAN NAMA FILE YANG LU PUNYA
import 'package:ravello/pages/verify_seller_Page.dart';
import 'package:ravello/pages/seller_dashboard.dart';

// === Providers ===
import 'package:ravello/providers/cart_provider.dart';
import 'package:ravello/providers/order_provider.dart';
import 'package:ravello/providers/address_provider.dart'; // <--- TAMBAHAN

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()), // <--- TAMBAHAN
      ],
      child: const RavelloApp(),
    ),
  );
}

class RavelloApp extends StatelessWidget {
  const RavelloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ravello E-Commerce',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF124170)),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreenWrapper(),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/cart': (context) => const CartPage(),
        '/checkout': (context) => const CheckoutPage(),
        '/profile': (context) => const ProfilePage(),
        '/favorite': (context) => const FavoritePage(),
        '/orders': (context) => const OrderPage(),

        // ⭐ Seller routes
        '/verify-seller': (context) => const VerifySellerPage(),
        // pastikan class di seller_dashboard.dart memang `SellerDashboardPage`
        '/seller-dashboard': (context) => const SellerDashboardPage(),
      },
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  const SplashScreenWrapper({super.key});

  @override
  State<SplashScreenWrapper> createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
    _navigateAfterSplash();
  }

  Future<void> _navigateAfterSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    if (kDebugMode) {
      // Saat debug, langsung ke home.
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Flow normal untuk release
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
