// lib/providers/address_provider.dart

import 'package:flutter/foundation.dart';
import '../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  AddressModel _address = AddressModel(
    name: 'Nama Penerima',
    address: 'Jl. Contoh No. 1, Kecamatan Contoh',
    city: 'Bekasi, Jawa Barat',
    phone: '+628123456789',
  );

  AddressModel get address => _address;

  void updateAddress(AddressModel newAddress) {
    _address = newAddress;
    notifyListeners();
  }

  // Optional: replace by parts
  void updateName(String name) {
    _address = _address.copyWith(name: name);
    notifyListeners();
  }

  void updatePhone(String phone) {
    _address = _address.copyWith(phone: phone);
    notifyListeners();
  }
}
