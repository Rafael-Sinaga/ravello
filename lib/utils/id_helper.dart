// lib/utils/id_helper.dart
//
// Helper defensif untuk menangani ID / angka dari backend
// yang bisa berupa int, num, String ("20"), atau null.
//
// Tujuan:
// - Tidak ada lagi error: type 'String' is not a subtype of type 'int'
// - Aman dipakai di seluruh aplikasi (productId, storeId, categoryId, dll)

extension DynamicIdParser on dynamic {
  /// Parse dynamic menjadi int?
  /// Aman untuk:
  /// - int
  /// - num
  /// - String angka ("20", "001", "20 ")
  /// - null
  int? asInt() {
    if (this == null) return null;

    if (this is int) return this;
    if (this is num) return this.toInt();

    if (this is String) {
      final cleaned = this.trim();
      if (cleaned.isEmpty) return null;
      return int.tryParse(cleaned);
    }

    return null;
  }

  /// Parse dynamic menjadi int dengan fallback default
  /// Cocok untuk UI yang BUTUH angka (counter, index, dll)
  int asIntOr(int fallback) {
    return asInt() ?? fallback;
  }

  /// Parse dynamic menjadi double?
  double? asDouble() {
    if (this == null) return null;

    if (this is double) return this;
    if (this is int) return this.toDouble();
    if (this is num) return this.toDouble();

    if (this is String) {
      final cleaned = this.replaceAll(',', '').trim();
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }

    return null;
  }

  /// Parse dynamic menjadi String? (aman)
  String? asString() {
    if (this == null) return null;
    return toString();
  }

  /// Cek apakah ID valid (int > 0)
  bool get hasValidId {
    final v = asInt();
    return v != null && v > 0;
  }
}
