import 'package:flutter/material.dart';
import 'package:ravello/pages/otp_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  InputDecoration _buildInputDecoration({
    required String label,
    String? hint,
    Widget? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefix,
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
    );
  }

  void _sendResetCode() {
    if (_emailController.text.isEmpty && _phoneController.text.isEmpty) {
      _showSnackBar('Harap masukkan email atau nomor telepon');
      return;
    }

    // Determine which method to use (email or phone)
    String contactInfo = '';
    if (_emailController.text.isNotEmpty) {
      contactInfo = _emailController.text;
    } else {
      contactInfo = _phoneController.text;
    }

    // Navigate to OTP page for password reset
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationPage(
          phoneNumber: contactInfo,
          onVerificationSuccess: () {
            // Callback ketika OTP berhasil diverifikasi
            // Bisa navigasi ke reset password page atau langsung login
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Kode verifikasi berhasil! Silakan buat kata sandi baru.'),
                backgroundColor: Colors.green,
              ),
            );
            // Navigator.push(...) untuk ke halaman reset password
          },
        ),
      ),
    );
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
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            
            // Title
            const Text(
              'Lupa Kata Sandi?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF273E47),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description text
            const Text(
              'Harap masukan nomor telepon / email yang sudah pernah di daftarkan.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Email Input
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _buildInputDecoration(
                label: 'Email',
                hint: 'Masukkan alamat email anda',
                prefix: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF6F7A74),
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Separator "atau"
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'atau',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.grey[400],
                    thickness: 1,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Phone Input
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _buildInputDecoration(
                label: 'Nomor Telepon',
                hint: 'Masukkan nomor telepon anda',
                prefix: const Icon(
                  Icons.phone_outlined,
                  color: Color(0xFF6F7A74),
                  size: 20,
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Send Reset Code Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendResetCode,
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
                  'Kirim Kode Reset',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Back to Login
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Kembali ke Masuk',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6180A0),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }
}