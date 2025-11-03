import 'package:flutter/material.dart';
import 'package:ravello/pages/login_page.dart';
import 'package:ravello/pages/register_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.08;
    // Keep a reasonable max for very large screens
    final effectivePadding = horizontalPadding.clamp(16.0, 64.0);

    return Scaffold(
      backgroundColor: Colors.white,
      // Let Scaffold resize when keyboard appears (default true).
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: effectivePadding),
                  child: Column(
                    // mainAxisSize: MainAxisSize.max so IntrinsicHeight is meaningful
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top spacer but bounded by IntrinsicHeight/ConstrainedBox
                      const SizedBox(height: 8),

                      // Logo (centered horizontally)
                      Center(
                        child: Image.asset(
                          'assets/images/ravello_logo.png',
                          width: screenWidth * 0.35,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return SizedBox(
                              width: screenWidth * 0.35,
                              height: screenWidth * 0.35,
                              child: const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            );
                          },
                        ),
                      ),

                      // vertical spacing tuned
                      SizedBox(height: constraints.maxHeight * 0.04),

                      // Title (ke kiri)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Selamat datang di\n',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  height: 1.1,
                                ),
                              ),
                              TextSpan(
                                text: 'Ravello',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF6F7A74),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Description
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Aplikasi e-commerce yang menghubungkanmu dengan produk terbaik. '
                          'Nikmati pengalaman belanja yang cerdas, efisien, dan penuh keuntungan setiap saat.',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15,
                            fontWeight: FontWeight.w300,
                            color: Color(0xFF6F7A74),
                            height: 1.6,
                          ),
                        ),
                      ),

                      // Flexible spacer: will push buttons to bottom when space available,
                      // but won't force overflow thanks to IntrinsicHeight/ConstrainedBox.
                      const Spacer(),

                      // Bottom buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                              );
                            },
                            child: const Text(
                              'Lanjut',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Color(0xFF6F7A74),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF273E47),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RegisterPage()),
                              );
                            },
                            child: const Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Space below buttons so they are not glued to SafeArea bottom
                      SizedBox(height: constraints.maxHeight * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
