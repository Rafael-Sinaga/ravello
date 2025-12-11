import 'package:flutter/material.dart';
import 'package:ravello/Services/auth_service.dart';
import 'package:ravello/pages/login_page.dart'; // Tambahkan import ini

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  InputDecoration _buildPasswordDecoration({
    required String label,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        color: Color(0xFF6F7A74),
      ),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: const Color(0xFFF2F4F4),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: Color(0xFF273E47), width: 2),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: const Color(0xFF6F7A74),
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }

  void _resetPassword() async {
  final newPass = _newPasswordController.text.trim();
  final confirmPass = _confirmPasswordController.text.trim();

  if (newPass.isEmpty || confirmPass.isEmpty) {
    _showSnackBar('Harap isi kedua kolom sandi');
    return;
  }
  if (newPass != confirmPass) {
    _showSnackBar('Konfirmasi kata sandi tidak sesuai');
    return;
  }
  if (newPass.length < 8) {
    _showSnackBar('Kata sandi minimal 8 karakter');
    return;
  }

  setState(() {});
  _showSnackBar("Mengirim perubahan...");

  final result = await AuthService.resetPassword(
    ModalRoute.of(context)!.settings.arguments as String? ?? "", // <= email
    newPass,
  );

  if (result['success'] == true) {
    _showSuccessAndNavigate();
  } else {
    _showSnackBar(result['message'] ?? 'Gagal menyimpan password');
  }
}


  void _showSuccessAndNavigate() {
    // Tampilkan snackbar sukses
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kata sandi berhasil direset!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigasi langsung ke login page setelah delay singkat
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            
            // Title
            const Text(
              'Reset Kata Sandi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description text
            const Text(
              'Buat sandi baru untuk akun anda\nPastikan sandi yang anda buat\nKuat dan Aman.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Password base
            const Text(
              'Masukan kata sandi baru',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF273E47),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // New Password Input
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNewPassword,
              decoration: _buildPasswordDecoration(
                label: 'Kata Sandi Baru',
                obscureText: _obscureNewPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Nonfirmati Password
            const Text(
              'Konfirmasi kata sandi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF273E47),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Confirm Password Input
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _buildPasswordDecoration(
                label: 'Konfirmasi Kata Sandi Baru',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            const Divider(
              color: Color(0xFFE8ECEB),
              thickness: 1,
            ),
            
            const SizedBox(height: 24),
            
            const SizedBox(height: 40),
            
            // Reset Password Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6180A0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Reset Kata Sandi',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}