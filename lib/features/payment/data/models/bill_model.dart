

import 'dart:convert';

class Bill {
  final String billId;
  final String orderId;
  final String tableId;
  final double totalAmount;
  final DateTime generatedAt;
  final String? shortOrderKey;

  const Bill({
    required this.billId,
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
    required this.generatedAt,
    this.shortOrderKey,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: json['billId'] as String,
      orderId: json['orderId'] as String,
      tableId: json['tableId'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      shortOrderKey: json['shortOrderKey'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'orderId': orderId,
      'tableId': tableId,
      'totalAmount': totalAmount,
      'generatedAt': generatedAt.toIso8601String(),
      if (shortOrderKey != null) 'shortOrderKey': shortOrderKey,
    };
  }

  String toJsonString() => jsonEncode(toJson());

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
    String? shortOrderKey,
  }) {
    return Bill(
      billId: billId ?? this.billId,
      orderId: orderId ?? this.orderId,
      tableId: tableId ?? this.tableId,
      totalAmount: totalAmount ?? this.totalAmount,
      generatedAt: generatedAt ?? this.generatedAt,
      shortOrderKey: shortOrderKey ?? this.shortOrderKey,
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
