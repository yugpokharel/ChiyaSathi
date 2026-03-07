import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AdminScanBillScreen extends StatefulWidget {
  const AdminScanBillScreen({super.key});

  @override
  State<AdminScanBillScreen> createState() => _AdminScanBillScreenState();
}

class _AdminScanBillScreenState extends State<AdminScanBillScreen> {
  String? billId;
  String? scannedData;

  void _onDetect(BarcodeCapture capture) {
    setState(() {
      scannedData = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Bill QR or Enter Bill ID')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Enter Bill ID',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => billId = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: billId == null || billId!.isEmpty
                  ? null
                  : () {
                      // TODO: Lookup bill by ID
                    },
              child: const Text('Lookup Bill'),
            ),
            const SizedBox(height: 32),
            const Text('Or scan QR below:'),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: MobileScanner(
                onDetect: _onDetect,
              ),
            ),
            if (scannedData != null) ...[
              const SizedBox(height: 24),
              Text('Scanned Data:'),
              Text(scannedData!),
              // TODO: Parse and lookup bill
            ],
          ],
        ),
      ),
    );
  }
}
