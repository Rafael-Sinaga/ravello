// lib/pages/otp_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravello/pages/reset_password.dart';
import 'login_page.dart';
import '../services/auth_service.dart';

class OTPVerificationPage extends StatefulWidget {
  final String identifier; // email
  final String actionFlow; // 'REGISTRATION' atau 'PASSWORD_RESET'

  const OTPVerificationPage({
    super.key,
    required this.identifier,
    required this.actionFlow,
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (index) => FocusNode());

  int _remainingSeconds = 60;
  Timer? _timer;

  bool _isSending = false;
  bool _isVerifying = false;

  static const Color _primaryColor = Color(0xFF124170);
  static const Color _backgroundColor = Color(0xFFF8FDFA);

  @override
  void initState() {
    super.initState();
    _setupOTPListeners();

    for (var node in _otpFocusNodes) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }

    _startTimer();
  }

  String _sanitizeMessage(dynamic raw,
      {String fallback =
          'Terjadi kesalahan pada server. Coba lagi nanti.'}) {
    String msg = (raw ?? '').toString();
    if (msg.contains('<!DOCTYPE') ||
        msg.contains('<html') ||
        msg.length > 300) {
      return fallback;
    }
    if (msg.contains('FormatException')) {
      return fallback;
    }
    return msg.isEmpty ? fallback : msg;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendOTP() async {
    setState(() => _isSending = true);

    try {
      final res = await AuthService.sendOtp(
        widget.identifier,
        actionFlow: widget.actionFlow,
      );

      final bool success = res['success'] == true;

      final String message = _sanitizeMessage(
        res['message'],
        fallback: success
            ? 'Kode OTP telah dikirim.'
            : 'Gagal mengirim OTP. Coba lagi.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? _primaryColor : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_sanitizeMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _resendOTP() {
    if (_remainingSeconds == 0 && !_isSending) {
      setState(() => _remainingSeconds = 60);
      _startTimer();
      _sendOTP();
    }
  }

  void _setupOTPListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < 5) {
          _otpFocusNodes[i + 1].requestFocus();
        }
        if (_otpControllers[i].text.isEmpty && i > 0) {
          _otpFocusNodes[i - 1].requestFocus();
        }
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (_isVerifying) return;

    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan kode OTP lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AuthService.verifyOtp(
        widget.identifier,
        otp,
        actionFlow: widget.actionFlow,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      final bool success = result['success'] == true;

      if (success) {
        final String message = _sanitizeMessage(
          result['message'],
          fallback: widget.actionFlow == 'PASSWORD_RESET'
              ? 'OTP benar! Silakan atur ulang password Anda.'
              : 'Akun berhasil dibuat. Silakan login.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.actionFlow == 'PASSWORD_RESET') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(),
              settings: RouteSettings(arguments: widget.identifier),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_sanitizeMessage(result['message'])),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_sanitizeMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  String _formatTime(int sec) {
    return "${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verifikasi Akun',
          style: TextStyle(
            color: _primaryColor,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// ============================
              ///  RESPONSIVE OTP BOXES
              /// ============================
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 10.0;
                  final totalSpacing = spacing * 5;
                  final available = constraints.maxWidth - totalSpacing;
                  final boxWidth =
                      (available / 6).clamp(44.0, 62.0); // responsif

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      return _buildOtpBox(i, boxWidth);
                    }),
                  );
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Masukkan 6 digit kode yang dikirim',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              /// TIMER + RESEND
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _remainingSeconds == 0 && !_isSending
                        ? _resendOTP
                        : null,
                    child: Text(
                      'Kirim ulang',
                      style: TextStyle(
                        color: _remainingSeconds == 0 && !_isSending
                            ? _primaryColor
                            : Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 28),

              /// BUTTON VERIFY
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isVerifying ? null : _verifyOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isVerifying
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Verifikasi',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ============================
  ///  FIXED OTP BOX (No Error)
  /// ============================
  Widget _buildOtpBox(int index, double width) {
    final filled = _otpControllers[index].text.isNotEmpty;
    final focused = _otpFocusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: width,
      height: 58,
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFE7F7EE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: focused ? 1.6 : 1,
          color: focused
              ? _primaryColor
              : (filled ? Colors.green.withOpacity(0.6) : const Color(0xFFE1E5EB)),
        ),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: const InputDecoration(
            counterText: "",
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() {});
            if (value.isNotEmpty && index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            }
            if (value.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }

            // AUTO VERIFY jika semua terisi
            if (_otpControllers.every((c) => c.text.length == 1) &&
                !_isVerifying) {
              _verifyOTP();
            }
          },
        ),
      ),
    );
  }
}