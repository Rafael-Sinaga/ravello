import '../services/auth_service.dart';
import '../services/seller_service.dart';
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
  final TextEditingController storeDescController = TextEditingController();
  final TextEditingController storeAddressController = TextEditingController();
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

  bool agreeTerms = false;
  XFile? ktpImage;
  XFile? faceImage;
  final ImagePicker picker = ImagePicker();
  bool isLoading = false;

  Future<void> _pickKtpImage() async {
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (pickedFile != null && mounted) {
      setState(() => ktpImage = pickedFile);
    }
  }

  Future<void> _takeKtpPhoto() async {
    final XFile? capturedFile =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (capturedFile != null && mounted) {
      setState(() => ktpImage = capturedFile);
    }
  }

  Future<void> _verifyFace() async {
    final XFile? capturedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (capturedFile != null && mounted) {
      setState(() => faceImage = capturedFile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifikasi wajah berhasil dilakukan.')),
      );
    }
  }

  Future<void> _submitVerification() async {
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap setujui Syarat & Ketentuan.')),
      );
      return;
    }

    if (nameController.text.isEmpty ||
        nikController.text.isEmpty ||
        ktpImage == null ||
        faceImage == null ||
        storeDescController.text.isEmpty ||
        storeAddressController.text.isEmpty ||
        selectedBank == null ||
        bankAccountController.text.isEmpty ||
        bankHolderController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data.')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await SellerService.registerStore(
        storeName: nameController.text.trim(),
        description: storeDescController.text.trim(),
        address: storeAddressController.text.trim(),
      );

      final prefs = await SharedPreferences.getInstance();

      if (result['success'] != true) {
        final msg = (result['message'] ?? '').toString().toLowerCase();
        final alreadySeller = msg.contains('sudah') || msg.contains('already');

        if (alreadySeller) {
          await AuthService.setSellerStatus(true);
          await AuthService.getStoreProfile();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SellerDashboardPage()),
          );
        }

        setState(() => isLoading = false);
        return;
      }

      final storeId = result['store_id'];
      if (storeId != null) {
        await prefs.setInt('store_id', storeId);
      }

      await AuthService.setSellerStatus(true);
      await AuthService.getStoreProfile();

      setState(() => isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SellerDashboardPage()),
      );
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF124170);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFD),
      appBar: AppBar(
        title: const Text(
          'Aktifkan Toko Anda',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EDFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Langkah terakhir sebelum tokomu bisa menerima pesanan.\n'
                    'Kami melakukan ini untuk melindungi penjual dan pembeli.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
                const SizedBox(height: 16),

                // ================== TAMBAHAN WAJIB ==================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: agreeTerms,
                      onChanged: (value) {
                        setState(() => agreeTerms = value ?? false);
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => agreeTerms = !agreeTerms);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ElevatedButton(
                onPressed: agreeTerms ? _submitVerification : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Aktifkan Toko',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
