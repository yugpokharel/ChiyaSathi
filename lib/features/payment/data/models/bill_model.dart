// bill_model.dart
// Chiya Sathi - Bill Model

import 'dart:convert';

class Bill {
  final String billId;
  final String orderId;
  final String tableId;
  final double totalAmount;
  final DateTime generatedAt;

  const Bill({
    required this.billId,
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
    required this.generatedAt,
  });

  /// Creates a Bill from a JSON map (e.g. parsed from QR code or API response)
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: json['billId'] as String,
      orderId: json['orderId'] as String,
      tableId: json['tableId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  /// Converts the Bill to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'orderId': orderId,
      'tableId': tableId,
      'totalAmount': totalAmount,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  /// Serialises to a JSON string (used for QR code data)
  String toJsonString() => jsonEncode(toJson());

  /// Deserialises from a JSON string (used when scanning QR code)
  static Bill fromJsonString(String jsonString) {
    final Map<String, dynamic> map =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return Bill.fromJson(map);
  }

  Bill copyWith({
    String? billId,
    String? orderId,
    String? tableId,
    double? totalAmount,
    DateTime? generatedAt,
  }) {
    return Bill(
      billId: billId ?? this.billId,
      orderId: orderId ?? this.orderId,
      tableId: tableId ?? this.tableId,
      totalAmount: totalAmount ?? this.totalAmount,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  String toString() {
    return 'Bill(billId: $billId, orderId: $orderId, tableId: $tableId, '
        'totalAmount: $totalAmount, generatedAt: $generatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bill && other.billId == billId;
  }

  @override
  int get hashCode => billId.hashCode;
}
