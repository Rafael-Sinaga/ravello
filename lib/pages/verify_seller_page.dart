import '../services/auth_service.dart';
import '../services/seller_service.dart'; // <--- IMPORT UNTUK HIT BACKEND
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'seller_dashboard.dart';

class VerifySellerPage extends StatefulWidget {
  const VerifySellerPage({super.key});

  @override
  State<VerifySellerPage> createState() => _VerifySellerPageState();
}

class _VerifySellerPageState extends State<VerifySellerPage> {
  String businessType = 'Perorangan';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController nikController = TextEditingController();

  // -------- INFORMASI TOKO (UNTUK BACKEND) --------
  final TextEditingController storeDescController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();

  // =============== REKENING BANK ===============
  final TextEditingController bankAccountController = TextEditingController();
  final TextEditingController bankHolderController = TextEditingController();
  String? selectedBank;

  final List<String> bankList = [
    'BCA',
    'BRI',
    'BNI',
    'Mandiri',
    'CIMB Niaga',
    'BTN',
    'Danamon',
    'Permata',
    'SeaBank',
  ];
  // ============================================

  bool agreeTerms = false;
  XFile? ktpImage;
  XFile? faceImage;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickKtpImage() async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (pickedFile != null && mounted) {
        setState(() {
          ktpImage = pickedFile;
        });
      }
    } catch (e) {
      debugPrint("Error picking KTP image: $e");
    }
  }

  Future<void> _takeKtpPhoto() async {
    try {
      final XFile? capturedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (capturedFile != null && mounted) {
        setState(() {
          ktpImage = capturedFile;
        });
      }
    } catch (e) {
      debugPrint("Error capturing KTP photo: $e");
    }
  }

  Future<void> _verifyFace() async {
    try {
      final XFile? capturedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.front,
      );
      if (capturedFile != null && mounted) {
        setState(() {
          faceImage = capturedFile;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verifikasi wajah berhasil dilakukan.')),
        );
      }
    } catch (e) {
      debugPrint("Error verifying face: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Gagal memverifikasi wajah. Coba lagi nanti.')),
      );
    }
  }

  Future<void> _submitVerification() async {
    // ------- VALIDASI FORM DASAR -------
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui Syarat & Ketentuan terlebih dahulu.'),
        ),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        nikController.text.isEmpty ||
        ktpImage == null ||
        faceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data sebelum konfirmasi.'),
        ),
      );
      return;
    }

    // VALIDASI deskripsi & alamat toko (buat ke backend)
    if (storeDescController.text.isEmpty ||
        storeAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Harap isi deskripsi toko dan alamat toko terlebih dahulu.'),
        ),
      );
      return;
    }

    // VALIDASI REKENING
    if (selectedBank == null ||
        bankAccountController.text.isEmpty ||
        bankHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi informasi rekening bank.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // ====== HIT BACKEND UNTUK DAFTAR TOKO ======
      final result = await SellerService.registerStore(
        storeName: nameController.text.trim(),
        description: storeDescController.text.trim(),
        address: storeAddressController.text.trim(),
      );

      if (result['success'] != true) {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Gagal mendaftar sebagai penjual.',
            ),
          ),
        );
        return;
      }

      // ====== JIKA SUKSES, SIMPAN LOKAL & UPDATE STATUS SELLER ======
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('storeName', nameController.text.trim());
      await prefs.setString('storeBankName', selectedBank ?? '');
      await prefs.setString(
          'storeBankAccountNumber', bankAccountController.text.trim());
      await prefs.setString(
          'storeBankAccountHolder', bankHolderController.text.trim());
      await prefs.setString(
          'storeAddress', storeAddressController.text.trim());
      await prefs.setString(
          'storeDescription', storeDescController.text.trim());

      // simpan store_id kalau dikirim backend
      final storeId = result['store_id'];
      if (storeId is int) {
        await prefs.setInt('storeId', storeId);
      }

      await prefs.setBool('isSeller', true);
      await AuthService.setSellerStatus(true);

      if (!mounted) return;
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? 'Verifikasi berhasil!',
          ),
        ),
      );

      // pindah ke dashboard penjual
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SellerDashboardPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickKtpImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _takeKtpPhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    nikController.dispose();
    storeDescController.dispose();
    storeAddressController.dispose();
    bankAccountController.dispose();
    bankHolderController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(fontSize: 13),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF124170), width: 1.4),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.withOpacity(0.15)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF124170);
    final Color backgroundColor = const Color(0xFFF8FBFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Verifikasi Data Diri',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF111827),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _submitVerification,
            child: const Text(
              'Simpan',
              style: TextStyle(color: Color(0xFF2563EB)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============== CARD 1: DATA USAHA & TOKO ==============
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jenis Usaha',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF124170),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Perorangan',
                                  style: TextStyle(fontSize: 13),
                                ),
                                value: 'Perorangan',
                                groupValue: businessType,
                                activeColor: primaryColor,
                                onChanged: (val) =>
                                    setState(() => businessType = val!),
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Perusahaan (PT/CV)',
                                  style: TextStyle(fontSize: 13),
                                ),
                                value: 'Perusahaan',
                                groupValue: businessType,
                                activeColor: primaryColor,
                                onChanged: (val) =>
                                    setState(() => businessType = val!),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: nameController,
                          maxLength: 50,
                          decoration: _fieldDecoration(
                            label: 'Nama Toko',
                            hint: 'Masukkan nama toko',
                          ).copyWith(counterText: ''),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: storeDescController,
                          maxLines: 3,
                          decoration: _fieldDecoration(
                            label: 'Deskripsi Toko',
                            hint: 'Ceritakan secara singkat tentang tokomu',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: storeAddressController,
                          maxLines: 2,
                          decoration: _fieldDecoration(
                            label: 'Alamat Toko',
                            hint: 'Alamat lengkap toko / gudang',
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: nikController,
                          maxLength: 16,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(
                            label: 'NIK',
                            hint: 'Masukkan NIK',
                          ).copyWith(counterText: ''),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============== CARD 2: INFORMASI REKENING ==============
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Rekening',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF124170),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedBank,
                          decoration: _fieldDecoration(
                            label: 'Pilih Bank',
                          ),
                          items: bankList.map((bank) {
                            return DropdownMenuItem(
                              value: bank,
                              child: Text(bank),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedBank = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bankAccountController,
                          keyboardType: TextInputType.number,
                          decoration: _fieldDecoration(
                            label: 'Nomor Rekening',
                            hint: 'Masukkan nomor rekening',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: bankHolderController,
                          decoration: _fieldDecoration(
                            label: 'Nama Pemilik Rekening',
                            hint: 'Masukkan nama pemilik rekening',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============== CARD 3: FOTO KTP & VERIFIKASI WAJAH ==============
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Foto KTP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF124170),
                          ),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _showImagePickerDialog,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              image: ktpImage != null
                                  ? DecorationImage(
                                      image: kIsWeb
                                          ? NetworkImage(ktpImage!.path)
                                          : FileImage(File(ktpImage!.path))
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: ktpImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.camera_alt_outlined,
                                        size: 32,
                                        color: Color(0xFF9CA3AF),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Unggah / ambil foto KTP',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pastikan seluruh KTP terlihat jelas dan tidak buram.',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Verifikasi Wajah',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF124170),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (faceImage != null)
                                    ClipOval(
                                      child: kIsWeb
                                          ? Image.network(
                                              faceImage!.path,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(faceImage!.path),
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            ),
                                    )
                                  else
                                    const Text(
                                      'Ambil foto wajah Anda untuk verifikasi.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _verifyFace,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: const Text(
                                'Verifikasi Sekarang',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ============== CARD 4: SYARAT & KETENTUAN ==============
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text.rich(
                            TextSpan(
                              text: 'Saya menyetujui ',
                              style: TextStyle(fontSize: 13),
                              children: [
                                TextSpan(
                                  text: 'Syarat & Ketentuan',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          value: agreeTerms,
                          onChanged: (val) =>
                              setState(() => agreeTerms = val ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Dengan melengkapi formulir ini, Penjual menyetujui bahwa:\n'
                          '• Informasi yang diberikan benar dan dapat diperbarui.\n'
                          '• Penjual memiliki hak dan kewenangan untuk menjual produk.\n'
                          '• Transaksi dianggap sah sesuai perjanjian yang berlaku.',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ============== BOTTOM ACTION BAR ==============
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                minimum:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: agreeTerms ? _submitVerification : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor:
                              primaryColor.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Konfirmasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ============== LOADING OVERLAY ==============
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
