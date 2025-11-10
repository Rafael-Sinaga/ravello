import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

class VerifySellerPage extends StatefulWidget {
  const VerifySellerPage({super.key});

  @override
  State<VerifySellerPage> createState() => _VerifySellerPageState();
}

class _VerifySellerPageState extends State<VerifySellerPage> {
  String businessType = 'Perorangan';
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  bool agreeTerms = false;
  File? ktpImage;
  File? faceImage;

  final ImagePicker picker = ImagePicker();

  Future<void> _pickKtpImage() async {
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        ktpImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takeKtpPhoto() async {
    final XFile? capturedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (capturedFile != null) {
      setState(() {
        ktpImage = File(capturedFile.path);
      });
    }
  }

  Future<void> _verifyFace() async {
    final XFile? capturedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.front,
    );
    if (capturedFile != null) {
      setState(() {
        faceImage = File(capturedFile.path);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verifikasi wajah berhasil dilakukan.')),
      );
    }
  }

  void _submitVerification() {
    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap setujui Syarat & Ketentuan terlebih dahulu.'),
        ),
      );
      return;
    }

    if (nameController.text.isEmpty || nikController.text.isEmpty || ktpImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap lengkapi semua data sebelum lanjut.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data berhasil dikirim untuk verifikasi.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Verifikasi Data Diri',
          style: TextStyle(fontWeight: FontWeight.bold),
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
            child: const Text('Simpan', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Usaha',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Perorangan'),
                    value: 'Perorangan',
                    groupValue: businessType,
                    onChanged: (val) => setState(() => businessType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Perusahaan (PT/CV)'),
                    value: 'Perusahaan',
                    groupValue: businessType,
                    onChanged: (val) => setState(() => businessType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'Nama',
                hintText: 'Masukkan nama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nikController,
              maxLength: 16,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NIK',
                hintText: 'Masukkan NIK',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Foto KTP',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _showImagePickerDialog(),
              child: Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  image: ktpImage != null
                      ? DecorationImage(
                          image: FileImage(ktpImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: ktpImage == null
                    ? const Center(
                        child: Icon(Icons.camera_alt_outlined,
                            size: 40, color: Colors.grey),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pastikan seluruh KTP berada dalam bingkai, info terlihat jelas, tidak buram.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Verifikasi Wajah',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: faceImage != null
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ClipOval(
                        child: Image.file(faceImage!,
                            width: 80, height: 80, fit: BoxFit.cover),
                      ),
                    )
                  : null,
              trailing: ElevatedButton(
                onPressed: _verifyFace,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700),
                child: const Text('Verifikasi Sekarang'),
              ),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text.rich(
                TextSpan(
                  text: 'Saya menyetujui ',
                  children: [
                    TextSpan(
                        text: 'Syarat & Ketentuan',
                        style: TextStyle(color: Colors.blue))
                  ],
                ),
              ),
              value: agreeTerms,
              onChanged: (val) => setState(() => agreeTerms = val ?? false),
            ),
            const SizedBox(height: 8),
            const Text(
              'Dengan melengkapi formulir ini, Penjual menyetujui bahwa:\n'
              '• Informasi yang diberikan benar dan dapat diperbarui.\n'
              '• Penjual memiliki hak dan kewenangan untuk menjual produk.\n'
              '• Transaksi dianggap sah sesuai perjanjian yang berlaku.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Kembali'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                    ),
                    child: const Text('Lanjut'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
}
