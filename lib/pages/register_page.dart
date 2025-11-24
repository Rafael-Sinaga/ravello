import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'otp_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  bool get isFormFilled =>
      nameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      passwordController.text.trim().isNotEmpty;

  Future<void> handleRegister() async {
    if (!isFormFilled) return;

    setState(() => isLoading = true);

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    final result = await AuthService.register(name, email, password);

    setState(() => isLoading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            phoneNumber: email, // backend kirim OTP ke email ini
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registrasi gagal: ${result['message']}')),
      );
    }
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Poppins', color: Color(0xFF9AA7AB)),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6E9EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE6E9EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF124170), width: 2),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Center(child: Image.asset('assets/images/ravello_logo.png', height: 96)),
              const SizedBox(height: 20),

              const Text(
                'Daftar Sekarang',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D3A43),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Buat akun untuk mulai berjualan & belanja. Isi detail di bawah ini.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: Color(0xFF8EA0A7),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),

              const Text('Nama Lengkap',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF273E47))),
              const SizedBox(height: 8),
              TextField(controller: nameController, decoration: _inputStyle('Masukan nama lengkap Anda')),
              const SizedBox(height: 14),

              const Text('Email',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF273E47))),
              const SizedBox(height: 8),
              TextField(
                  controller: emailController,
                  decoration: _inputStyle('contoh@mail.com'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),

              const Text('Kata Sandi',
                  style: TextStyle(
                      fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF273E47))),
              const SizedBox(height: 8),
              TextField(controller: passwordController, obscureText: true, decoration: _inputStyle('Minimal 8 karakter')),
              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || !isFormFilled ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF124170),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Daftar',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),

              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                  },
                  child: const Text('Sudah punya akun? Masuk',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Color(0xFF124170))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
