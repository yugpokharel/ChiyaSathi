import 'package:flutter/material.dart';

class GenerateBillScreen extends StatelessWidget {
  final String orderId;
  final String tableId;
  final double totalAmount;

  const GenerateBillScreen({
    super.key,
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Bill')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: $orderId'),
            Text('Table ID: $tableId'),
            Text('Total: Rs. ${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Pay Online (Coming Soon)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/show_qr', arguments: {
                  'orderId': orderId,
                  'tableId': tableId,
                  'totalAmount': totalAmount,
                });
              },
              child: const Text('Pay on Counter'),
            ),
          ],
        ),
      ),
    );
  }
}
