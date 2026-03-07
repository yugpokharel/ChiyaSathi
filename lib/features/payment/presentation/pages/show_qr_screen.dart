// show_qr_screen.dart
// Chiya Sathi - Show QR Screen

import 'package:chiya_sathi/features/payment/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// A screen that renders a QR code encoding the full [Bill] as JSON.
///
/// The QR payload is [Bill.toJsonString()], so [AdminScanBillScreen] can
/// decode it back to a [Bill] object after scanning.
///
/// Dependency: add `qr_flutter` to pubspec.yaml
/// ```yaml
/// dependencies:
///   qr_flutter: ^4.1.0
/// ```
class ShowQrScreen extends StatelessWidget {
  final Bill bill;

  const ShowQrScreen({super.key, required this.bill});

  @override
  Widget build(BuildContext context) {
    final qrData = bill.toJsonString();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text('Bill QR Code'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B3F1A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Copy bill data',
            icon: const Icon(Icons.copy_rounded),
            onPressed: () => _copyToClipboard(context, qrData),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QrCard(bill: bill, qrData: qrData),
            const SizedBox(height: 24),
            _BillDetailCard(bill: bill),
            const SizedBox(height: 24),
            _InstructionBanner(),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bill data copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF6B3F1A),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// QR card
// ---------------------------------------------------------------------------

class _QrCard extends StatelessWidget {
  final Bill bill;
  final String qrData;

  const _QrCard({required this.bill, required this.qrData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            // Shop logo / header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_cafe_rounded,
                    color: Color(0xFF6B3F1A), size: 28),
                const SizedBox(width: 8),
                Text(
                  'Chiya Sathi',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6B3F1A),
                      ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // QR code
            QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 240,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF6B3F1A),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF2C1A0E),
              ),
              embeddedImageStyle: const QrEmbeddedImageStyle(size: Size(40, 40)),
            ),

            const SizedBox(height: 20),
            Text(
              'Bill ID: ${bill.billId}',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bill detail card
// ---------------------------------------------------------------------------

class _BillDetailCard extends StatelessWidget {
  final Bill bill;

  const _BillDetailCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bill Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B3F1A),
                  ),
            ),
            const Divider(height: 24),
            _Row(label: 'Bill ID', value: bill.billId),
            const SizedBox(height: 10),
            _Row(label: 'Order ID', value: bill.orderId),
            const SizedBox(height: 10),
            _Row(label: 'Table', value: bill.tableId),
            const SizedBox(height: 10),
            _Row(
              label: 'Generated At',
              value: _fmt(bill.generatedAt),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                Text(
                  'Rs. ${bill.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF6B3F1A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${_p(dt.month)}-${_p(dt.day)}  ${_p(dt.hour)}:${_p(dt.minute)}';
  String _p(int n) => n.toString().padLeft(2, '0');
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Instruction banner
// ---------------------------------------------------------------------------

class _InstructionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE0D4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6B3F1A).withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: Color(0xFF6B3F1A), size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ask the cashier to scan this QR code to verify and settle your bill.',
              style: TextStyle(fontSize: 13, color: Color(0xFF4A2C0A)),
            ),
          ),
        ],
      ),
    );
  }
}
