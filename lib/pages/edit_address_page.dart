// lib/pages/edit_address_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address_model.dart';
import '../providers/address_provider.dart';

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameC;
  late TextEditingController _addressC;
  late TextEditingController _cityC;
  late TextEditingController _phoneC;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final addr = Provider.of<AddressProvider>(context, listen: false).address;
      _nameC = TextEditingController(text: addr.name);
      _addressC = TextEditingController(text: addr.address);
      _cityC = TextEditingController(text: addr.city);
      _phoneC = TextEditingController(text: addr.phone);
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _addressC.dispose();
    _cityC.dispose();
    _phoneC.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final newAddr = AddressModel(
      name: _nameC.text.trim(),
      address: _addressC.text.trim(),
      city: _cityC.text.trim(),
      phone: _phoneC.text.trim(),
    );
    Provider.of<AddressProvider>(context, listen: false).updateAddress(newAddr);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const Color textColor = Color(0xFF124170);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text('Edit Alamat', style: TextStyle(color: textColor)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Nama Penerima'),
                validator: (v) => (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressC,
                decoration: const InputDecoration(labelText: 'Alamat lengkap'),
                validator: (v) => (v == null || v.isEmpty) ? 'Alamat tidak boleh kosong' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityC,
                decoration: const InputDecoration(labelText: 'Kota / Kecamatan'),
                validator: (v) => (v == null || v.isEmpty) ? 'Kota tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneC,
                decoration: const InputDecoration(labelText: 'Nomor Telepon'),
                validator: (v) => (v == null || v.isEmpty) ? 'No. telepon tidak boleh kosong' : null,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
