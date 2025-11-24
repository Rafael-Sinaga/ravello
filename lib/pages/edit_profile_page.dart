import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController = TextEditingController(text: "Nama Pengguna");
  final TextEditingController emailController = TextEditingController(text: "email@example.com");
  final TextEditingController phoneController = TextEditingController(text: "08xxxxxxxxxx");

  File? selectedImage;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Foto Profil
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: selectedImage != null
                      ? FileImage(selectedImage!)
                      : const AssetImage("assets/default_profile.png") as ImageProvider,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Nama
          const Text(
            "Nama",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Masukkan Nama",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 20),

          // Email
          const Text(
            "Email",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: "Masukkan Email",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          const SizedBox(height: 20),

          // Nomor Telepon
          const Text(
            "Nomor Telepon",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: phoneController,
            decoration: InputDecoration(
              hintText: "Masukkan Nomor Telepon",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.phone,
          ),

          const SizedBox(height: 40),

          // Tombol Simpan
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Integrasi ke backend jika dibutuhkan
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Perubahan disimpan")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Simpan Perubahan"),
            ),
          ),
        ],
      ),
    );
  }
}
