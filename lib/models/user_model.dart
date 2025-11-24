class UserModel {
  final int id;
  final String name;
  final String email;
  bool isSeller;   // <--- Tambahan field baru (boleh mutable)

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isSeller = false,   // <--- Default aman
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['client_id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isSeller: json['isSeller'] ?? false,   // <--- Tambahan aman
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'isSeller': isSeller,  // <--- Tambahan
    };
  }
}
