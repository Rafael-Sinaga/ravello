import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ravello/pages/login_page.dart'; // diganti: arahkan ke LoginPage setelah verifikasi

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final VoidCallback? onVerificationSuccess;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    this.onVerificationSuccess,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController()
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode()
  );

  int _remainingSeconds = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _setupOTPListeners();
    _startTimer();
    // In a real app, you would send OTP to the phone number here
    _sendOTP();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _sendOTP() {
    // Implement your OTP sending logic here
    // This would typically call your backend API
    print('Sending OTP to: ${widget.phoneNumber}');
    // Mock OTP sending
    Future.delayed(const Duration(seconds: 1), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kode OTP telah dikirim ke ${widget.phoneNumber}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }

  void _resendOTP() {
    if (_remainingSeconds == 0) {
      setState(() {
        _remainingSeconds = 60;
      });
      _startTimer();
      _sendOTP();
    }
  }

  void _setupOTPListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < _otpControllers.length - 1) {
          _otpFocusNodes[i + 1].requestFocus();
        }

        if (_otpControllers[i].text.isEmpty && i > 0) {
          _otpFocusNodes[i - 1].requestFocus();
        }
      });
    }
  }

  void _verifyOTP() {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length == 6) {
      // Implement your OTP verification logic here
      // This would typically call your backend API
      print('Verifying OTP: $otp for ${widget.phoneNumber}');

      // Mock verification - replace with actual API call
      _mockVerifyOTP(otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan kode OTP lengkap'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mockVerifyOTP(String otp) {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Mock API call delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Remove loading

      // For demo purposes, assume OTP '123456' is always valid
      if (otp == '123456') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verifikasi berhasil!'),
            backgroundColor: Colors.green,
          ),
        );

        // Call success callback jika masih diperlukan untuk use case lain
        widget.onVerificationSuccess?.call();

        // Arahkan ke halaman Login (seharusnya setelah registrasi dan OTP valid)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode OTP salah, coba lagi'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              Text(
                'Masukkan Kode OTP',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              // Description text with phone number
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Kami telah mengirimkan kode OTP ke ',
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF273E47),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Timer
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Resend text
              GestureDetector(
                onTap: _remainingSeconds == 0 ? _resendOTP : null,
                child: Text(
                  'Kirim ulang kode OTP',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: _remainingSeconds == 0
                        ? const Color(0xFF6180A0)
                        : Colors.grey[400],
                    fontWeight: _remainingSeconds == 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // OTP Input Fields - DIUBAH LEBIH BESAR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 52, // Diperbesar dari 45
                    height: 52, // Diperbesar dari 45
                    child: TextField(
                      controller: _otpControllers[index],
                      focusNode: _otpFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // Border radius diperbesar
                          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6180A0), width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20, // Font size diperbesar
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          _otpFocusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 60),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6180A0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verifikasi Kode OTP',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Resend OTP option
              Center(
                child: TextButton(
                  onPressed: _remainingSeconds == 0 ? _resendOTP : null,
                  child: Text(
                    'Kirim ulang kode OTP',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: _remainingSeconds == 0
                          ? const Color(0xFF6180A0)
                          : Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
