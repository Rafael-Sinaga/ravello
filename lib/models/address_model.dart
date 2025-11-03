// lib/models/address_model.dart

class AddressModel {
  final String name;
  final String address;
  final String city;
  final String phone;

  AddressModel({
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
  });

  AddressModel copyWith({
    String? name,
    String? address,
    String? city,
    String? phone,
  }) {
    return AddressModel(
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
    );
  }

  @override
  String toString() {
    return '$name — $address, $city — $phone';
  }
}
