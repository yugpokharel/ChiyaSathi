class BillModel {
  final String billId;
  final String orderId;
  final String tableId;
  final double totalAmount;
  final DateTime generatedAt;

  BillModel({
    required this.billId,
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
    required this.generatedAt,
  });
}
