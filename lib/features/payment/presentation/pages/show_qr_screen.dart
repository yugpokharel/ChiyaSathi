import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

String generateUniqueBillId() {
  final now = DateTime.now().millisecondsSinceEpoch;
  final rand = Random().nextInt(999999);
  return 'BILL${now}_$rand';
}

class ShowQrScreen extends StatelessWidget {
  final String orderId;
  final String tableId;
  final double totalAmount;

  const ShowQrScreen({
    super.key,
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final billId = generateUniqueBillId();
    final qrData = '{"billId":"$billId","orderId":"$orderId","tableId":"$tableId","totalAmount":$totalAmount}';
    return Scaffold(
      appBar: AppBar(title: const Text('Show QR at Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImage(
              data: qrData,
              size: 220,
            ),
            const SizedBox(height: 24),
            Text('Show this QR at the counter'),
            const SizedBox(height: 12),
            Text('Bill ID: $billId'),
          ],
        ),
      ),
    );
  }
}
