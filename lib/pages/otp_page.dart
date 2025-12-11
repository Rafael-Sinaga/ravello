// lib/pages/otp_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // untuk inputFormatters
import 'login_page.dart';
import '../services/auth_service.dart';

class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber; // sebenernya ini email, tapi dipakai sebagai identifier

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
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
    // listener tambahan supaya AnimatedContainer ikut update saat fokus berubah
    for (final node in _otpFocusNodes) {
      node.addListener(() {
        if (mounted) setState(() {});
      });
    }
    _startTimer();
    _sendOTP();
  }

  // === HELPER UNTUK BERSIHKAN PESAN ERROR ===
  String _sanitizeMessage(
    dynamic raw, {
    String fallback = 'Terjadi kesalahan pada server. Coba lagi nanti.',
  }) {
    String msg = (raw ?? '').toString();

    // Kalau pesan berisi HTML / DOCTYPE, jangan tampilkan mentah-mentah
    if (msg.contains('<!DOCTYPE') || msg.contains('<html') || msg.length > 300) {
      return fallback;
    }

    // Kalau pesan FormatException JSON jelek
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
    setState(() {
      _isSending = true;
    });

    try {
      final res = await AuthService.sendOtp(widget.phoneNumber);

      final bool success = res['success'] == true;
      final String message = _sanitizeMessage(
        res['message'],
        fallback: success
            ? 'Kode OTP telah dikirim.'
            : 'Gagal mengirim OTP. Coba lagi beberapa saat.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? _primaryColor : Colors.red,
        ),
      );
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koneksi ke server melebihi batas waktu. Coba lagi beberapa saat.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // Jangan tampilkan <!DOCTYPE ...> ke user
      final String message = _sanitizeMessage(
        e,
        fallback:
            'Terjadi kesalahan koneksi ke server. Silakan coba lagi beberapa saat.',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
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

    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan kode OTP lengkap'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AuthService.verifyOtp(widget.phoneNumber, otp);

      if (!mounted) return;
      Navigator.of(context).pop(); // tutup dialog

      final bool success = result['success'] == true;

      if (success) {
        final String message = _sanitizeMessage(
          result['message'],
          fallback: 'Akun berhasil didaftarkan dan sudah aktif.',
        );

        // 🔵 NOTIF SUKSES → HIJAU
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil diaktivasi. Silakan login.'),
            backgroundColor: Color(0xFF16A34A), // hijau sukses
          ),
        );

        // 🔁 OPSIONAL: bersihkan OTP dan timer biar rapih
        _timer?.cancel();

        // ✅ AUTO DIRECT KE HALAMAN LOGIN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        final String message = _sanitizeMessage(
          result['message'],
          fallback: 'Verifikasi gagal. Coba lagi beberapa saat.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException {
      if (mounted) {
        Navigator.of(context).pop(); // tutup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verifikasi memakan waktu terlalu lama. Coba lagi beberapa saat.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // tutup dialog

        final String message = _sanitizeMessage(
          e,
          fallback:
              'Terjadi kesalahan koneksi ke server. Silakan coba lagi beberapa saat.',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    for (var n in _otpFocusNodes) {
      n.dispose();
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
        centerTitle: true,
        title: const Text(
          'Verifikasi Akun',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  // HEADER KARTU ESTETIK
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.verified_user_outlined,
                            color: _primaryColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Masukkan Kode OTP',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _primaryColor,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kami telah mengirimkan kode OTP ke ${widget.phoneNumber}. Silakan masukkan kode yang diterima untuk menyelesaikan verifikasi.',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Color(0xFF8EA0A7),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 14,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Kode ini bersifat rahasia, jangan bagikan ke siapa pun.',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 11,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // OTP SECTION
                  Center(
                    child: Column(
                      children: [
                        _buildOtpRow(),
                        const SizedBox(height: 12),
                        const Text(
                          'Masukkan 6 digit kode yang kamu terima',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF4FA),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: Color(0xFF6B7A8C),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(_remainingSeconds),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF273E47),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '|\u00A0',
                                style: TextStyle(
                                  color: Color(0xFFB0BAC5),
                                  fontSize: 12,
                                ),
                              ),
                              GestureDetector(
                                onTap: _remainingSeconds == 0 && !_isSending
                                    ? _resendOTP
                                    : null,
                                child: Row(
                                  children: [
                                    if (_isSending)
                                      const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                              _primaryColor),
                                        ),
                                      ),
                                    if (_isSending) const SizedBox(width: 6),
                                    Text(
                                      'Kirim ulang',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: _remainingSeconds == 0 &&
                                                !_isSending
                                            ? _primaryColor
                                            : Colors.grey[400],
                                        fontWeight: _remainingSeconds == 0 &&
                                                !_isSending
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 26),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _verifyOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor.withOpacity(
                                  _isVerifying ? 0.6 : 1.0),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 3,
                              shadowColor:
                                  _primaryColor.withOpacity(0.35),
                            ),
                            child: _isVerifying
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Verifikasi Kode OTP',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  Center(
                    child: TextButton(
                      onPressed: _remainingSeconds == 0 && !_isSending
                          ? _resendOTP
                          : null,
                      child: Text(
                        'Tidak menerima kode? Kirim ulang',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: _remainingSeconds == 0 && !_isSending
                              ? _primaryColor
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== UI HELPER: ROW OTP RESPONSIF ==================

  Widget _buildOtpRow() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // sisakan sedikit ruang di kiri/kanan
        final double totalWidth = constraints.maxWidth;
        const double spacing = 8.0;
        final double rawBoxWidth = (totalWidth - (spacing * 5)) / 6;
        final double boxWidth = rawBoxWidth.clamp(44.0, 56.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing / 2),
              child: _buildOtpBox(index, boxWidth),
            );
          }),
        );
      },
    );
  }

  // ================== UI HELPER: KOTAK OTP ==================

  Widget _buildOtpBox(int index, double width) {
    final bool filled = _otpControllers[index].text.isNotEmpty;
    final bool isFocused = _otpFocusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: width,
      height: 60,
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFE7F7EE) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
        border: Border.all(
          width: isFocused ? 1.6 : 1.1,
          color: isFocused
              ? _primaryColor
              : (filled
                  ? const Color(0xFF22A45D).withOpacity(0.7)
                  : const Color(0xFFE1E5EB)),
        ),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          // ⬇️ HAPUS const DI SINI, BIARKAN BIASA SAJA
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            isCollapsed: true,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            setState(() {});
            if (v.length == 1 && index < 5) {
              _otpFocusNodes[index + 1].requestFocus();
            }
            if (v.isEmpty && index > 0) {
              _otpFocusNodes[index - 1].requestFocus();
            }

            // ✅ AUTO VERIFY: kalau semua kotak sudah terisi, langsung verifikasi
            final bool allFilled =
                _otpControllers.every((c) => c.text.length == 1);
            if (allFilled && !_isVerifying) {
              _verifyOTP();
            }
          },
        ),
      ),
    );
  }
}
