class AppNotification {
  final String id;

  /// buyer | seller
  final String role;

  /// Judul notifikasi
  final String title;

  /// Isi notifikasi
  final String message;

  /// Data tambahan (orderId, items, status, dll)
  final Map<String, dynamic>? data;

  /// Sudah dibaca atau belum
  bool isRead;

  /// Waktu dibuat
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.role,
    required this.title,
    required this.message,
    required this.createdAt,
    this.data,
    this.isRead = false,
  });

  /// Optional (kalau suatu saat mau persist ke local / backend)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      role: json['role'],
      title: json['title'],
      message: json['message'],
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
