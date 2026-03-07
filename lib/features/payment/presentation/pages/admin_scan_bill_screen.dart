

import 'package:chiya_sathi/features/payment/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Simulated backend lookup by [billId].
///
/// Replace this with a real HTTP / database call in production.
Future<Bill?> _lookupBillById(String billId) async {
  await Future.delayed(const Duration(milliseconds: 600));

  // Simulated database of bills
  final mockDb = <String, Map<String, dynamic>>{
    'BILL-001': {
      'billId': 'BILL-001',
      'orderId': 'ORD-2024-001',
      'tableId': 'T-01',
      'totalAmount': 350.00,
      'generatedAt': '2024-01-15T10:30:00.000',
    },
    'BILL-002': {
      'billId': 'BILL-002',
      'orderId': 'ORD-2024-002',
      'tableId': 'T-05',
      'totalAmount': 720.50,
      'generatedAt': '2024-01-15T11:15:00.000',
    },
  };

  final data = mockDb[billId];
  if (data == null) return null;
  return Bill.fromJson(data);
}

/// Admin screen to scan a customer's QR bill or look it up by [billId].
///
/// Dependencies – add to pubspec.yaml:
/// ```yaml
/// dependencies:
///   mobile_scanner: ^5.2.3
/// ```
///
/// Android: add camera permission to AndroidManifest.xml
/// iOS:     add NSCameraUsageDescription to Info.plist
class AdminScanBillScreen extends StatefulWidget {
  const AdminScanBillScreen({super.key});

  @override
  State<AdminScanBillScreen> createState() => _AdminScanBillScreenState();
}

class _AdminScanBillScreenState extends State<AdminScanBillScreen>
    with WidgetsBindingObserver {
  // ── Camera controller ──────────────────────────────────────────────────────
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  // ── Manual entry ───────────────────────────────────────────────────────────
  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ── State ──────────────────────────────────────────────────────────────────
  bool _isScanning = true;   // true = camera tab, false = manual tab
  bool _isLoading = false;
  bool _dialogOpen = false;  // guard against double-open

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_cameraController.value.isInitialized) return;
    if (state == AppLifecycleState.paused) {
      _cameraController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _cameraController.start();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController.dispose();
    _manualController.dispose();
    _manualFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // QR detection handler
  // ---------------------------------------------------------------------------

  void _onDetect(BarcodeCapture capture) {
    if (_dialogOpen || _isLoading) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _cameraController.stop();
    _processRawValue(rawValue);
  }

  // ---------------------------------------------------------------------------
  // Core processing – shared by QR scan and manual entry
  // ---------------------------------------------------------------------------

  Future<void> _processRawValue(String rawValue) async {
    setState(() => _isLoading = true);

    try {
      Bill? bill;

      // 1. Try to parse as a full JSON bill (from QR)
      if (rawValue.trimLeft().startsWith('{')) {
        try {
          bill = Bill.fromJsonString(rawValue);
        } catch (_) {
          // JSON was malformed – fall through to ID lookup
        }
      }

      // 2. Otherwise treat it as a plain billId (manual entry or simple QR)
      if (bill == null) {
        bill = await _lookupBillById(rawValue.trim());
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (bill == null) {
        _showErrorSnackBar('Bill "$rawValue" not found.');
        _cameraController.start();
        return;
      }

      _showBillDialog(bill);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error: ${e.toString()}');
      _cameraController.start();
    }
  }

  // ---------------------------------------------------------------------------
  // Manual lookup
  // ---------------------------------------------------------------------------

  void _onManualLookup() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _processRawValue(_manualController.text.trim());
  }

  // ---------------------------------------------------------------------------
  // Dialog
  // ---------------------------------------------------------------------------

  void _showBillDialog(Bill bill) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BillDialog(
        bill: bill,
        onSettle: () {
          Navigator.of(context).pop(); // close dialog
          _dialogOpen = false;
          _cameraController.start();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Bill ${bill.billId} marked as settled ✓'),
              backgroundColor: const Color(0xFF3A7D44),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop();
          _dialogOpen = false;
          _cameraController.start();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A0E06),
      appBar: AppBar(
        title: const Text('Admin – Scan Bill'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B3F1A),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _TabBar(
            isScanning: _isScanning,
            onTab: (v) {
              setState(() => _isScanning = v);
              if (v) {
                _cameraController.start();
              } else {
                _cameraController.stop();
              }
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_isScanning) _ScannerView(
            controller: _cameraController,
            onDetect: _onDetect,
          ) else _ManualEntryView(
            formKey: _formKey,
            controller: _manualController,
            focusNode: _manualFocus,
            isLoading: _isLoading,
            onLookup: _onManualLookup,
          ),
          if (_isLoading)
            const _LoadingOverlay(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab bar
// ---------------------------------------------------------------------------

class _TabBar extends StatelessWidget {
  final bool isScanning;
  final ValueChanged<bool> onTab;

  const _TabBar({required this.isScanning, required this.onTab});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _Tab(
            label: 'Scan QR',
            icon: Icons.qr_code_scanner_rounded,
            selected: isScanning,
            onTap: () => onTab(true),
          ),
          const SizedBox(width: 12),
          _Tab(
            label: 'Enter ID',
            icon: Icons.keyboard_rounded,
            selected: !isScanning,
            onTap: () => onTab(false),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? Colors.white.withOpacity(0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: Colors.white54)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: Colors.white,
                  size: 18),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scanner view
// ---------------------------------------------------------------------------

class _ScannerView extends StatelessWidget {
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  const _ScannerView({required this.controller, required this.onDetect});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
        ),
        // Scan overlay
        Center(
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF5A623), width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Point camera at the customer\'s bill QR code',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Manual entry view
// ---------------------------------------------------------------------------

class _ManualEntryView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onLookup;

  const _ManualEntryView({
    required this.formKey,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onLookup,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F0EB),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.receipt_long_rounded,
                color: Color(0xFF6B3F1A), size: 64),
            const SizedBox(height: 24),
            Text(
              'Enter Bill ID',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B3F1A),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type or paste the bill ID to look up the bill details.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Bill ID',
                hintText: 'e.g. BILL-001',
                prefixIcon: const Icon(Icons.tag_rounded,
                    color: Color(0xFF6B3F1A)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF6B3F1A), width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Please enter a bill ID';
                }
                return null;
              },
              onFieldSubmitted: (_) => onLookup(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onLookup,
              icon: const Icon(Icons.search_rounded),
              label: const Text('Look Up Bill',
                  style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B3F1A),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Hint for test data
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDE0D4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '💡 Try demo IDs: BILL-001 or BILL-002',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF4A2C0A)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bill dialog
// ---------------------------------------------------------------------------

class _BillDialog extends StatelessWidget {
  final Bill bill;
  final VoidCallback onSettle;
  final VoidCallback onCancel;

  const _BillDialog({
    required this.bill,
    required this.onSettle,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.receipt_rounded,
              color: Color(0xFF6B3F1A), size: 24),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Bill Details',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFF6B3F1A)),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(),
          _DialogRow(label: 'Bill ID', value: bill.billId),
          _DialogRow(label: 'Order ID', value: bill.orderId),
          _DialogRow(label: 'Table', value: bill.tableId),
          _DialogRow(
            label: 'Generated',
            value: _fmt(bill.generatedAt),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
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
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel',
              style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          onPressed: onSettle,
          icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
          label: const Text('Mark as Settled'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A7D44),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.year}-${_p(dt.month)}-${_p(dt.day)}  ${_p(dt.hour)}:${_p(dt.minute)}';
  String _p(int n) => n.toString().padLeft(2, '0');
}

class _DialogRow extends StatelessWidget {
  final String label;
  final String value;

  const _DialogRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading overlay
// ---------------------------------------------------------------------------

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF6B3F1A)),
                SizedBox(height: 16),
                Text('Looking up bill…'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
