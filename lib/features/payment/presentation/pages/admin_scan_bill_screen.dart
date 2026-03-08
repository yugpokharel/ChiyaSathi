import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chiya_sathi/features/payment/data/models/bill_model.dart';
import 'package:chiya_sathi/features/payment/presentation/pages/generate_bill_screen.dart'; 
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:chiya_sathi/core/services/notification_service.dart';

class BillStore {
  static final Map<String, Bill> _bills = {};

  static void addBill(Bill bill) {
    _bills[bill.billId] = bill;
  }

  static Bill? getBill(String billId) => _bills[billId];
}
Future<Bill?> _lookupBillById(String billId) async {
  await Future.delayed(const Duration(milliseconds: 600));
  final bill = BillStore.getBill(billId);
  if (bill != null) return bill;

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

Future<Order?> fetchOrderById(String orderId) async {
  final response = await http.get(Uri.parse('https://your-backend.com/api/orders/$orderId'));
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return Order.fromJson(json);
  } else {
    return null;
  }
}

class Order {
  final String id;
  final String customerName;
  final List<String> items;
  final String paymentStatus;

  Order({required this.id, required this.customerName, required this.items, required this.paymentStatus});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      items: List<String>.from(json['items'] as List),
      paymentStatus: json['paymentStatus'] as String,
    );
  }
}

class AdminScanBillScreen extends StatefulWidget {
  const AdminScanBillScreen({super.key});

  @override
  State<AdminScanBillScreen> createState() => _AdminScanBillScreenState();
}

class _AdminScanBillScreenState extends State<AdminScanBillScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  final TextEditingController _manualController = TextEditingController();
  final FocusNode _manualFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isScanning = true;   
  bool _isLoading = false;
  bool _dialogOpen = false;  


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final demoBill = Bill(
      billId: 'chai-latte-sathi-order',
      orderId: 'ORD-2024-001',
      tableId: 'T-01',
      totalAmount: 350.00,
      generatedAt: DateTime.now(),
      shortOrderKey: 'abcd',
    );
    BillStore.addBill(demoBill);
    OrderKeyStore.add('abcd', 'ORD-2024-001');
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


  void _onDetect(BarcodeCapture capture) {
    if (_dialogOpen || _isLoading) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    _cameraController.stop();
    _processRawValue(rawValue);
  }


  Future<void> _processRawValue(String rawValue) async {
    setState(() => _isLoading = true);

    try {
      Bill? bill;
      String input = rawValue.trim();

      // Debug: print available keys
      debugPrint('AdminScanBillScreen: input="$input"');
      debugPrint('BillStore keys: ${BillStore._bills.keys.toList()}');
      debugPrint('OrderKeyStore keys: ${OrderKeyStore.keyToOrderId.keys.toList()}');

      // Try JSON decode
      if (input.startsWith('{')) {
        try {
          bill = Bill.fromJsonString(input);
        } catch (_) {}
      }

      // Try billId lookup
      if (bill == null) {
        bill = await _lookupBillById(input);
      }

      // Try short order key lookup
      if (bill == null) {
        final mappedOrderId = OrderKeyStore.getOrderId(input);
        debugPrint('OrderKeyStore.getOrderId("$input") = $mappedOrderId');
        if (mappedOrderId != null) {
          final bills = BillStore._bills.values.where((b) => b.orderId == mappedOrderId);
          bill = bills.isNotEmpty ? bills.first : null;
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (bill == null) {
        _showErrorSnackBar('Bill or order key "$input" not found.');
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

  void _onManualLookup() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    _processRawValue(_manualController.text.trim());
  }



  void _showBillDialog(Bill bill) {
    if (_dialogOpen) return;
    _dialogOpen = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BillDialog(
        bill: bill,
        onSettle: () async {
          Navigator.of(context).pop(); // close dialog
          _dialogOpen = false;
          _cameraController.start();
          // Settle the order (simulate or call backend here)
          // Send push notification to user
          await NotificationService().showOrderNotification(
            title: 'Order Settled',
            body: 'Thank you for ordering with ChiyaSathi',
          );
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


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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
              'Enter Bill ID or Short Order Key',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6B3F1A),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type or paste the bill ID or short order key to look up the bill details.',
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
              textCapitalization: TextCapitalization.none,
              decoration: InputDecoration(
                labelText: 'Bill ID or Order Key',
                hintText: 'e.g. chai-latte-sathi-order or abcd',
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
                  return 'Please enter a bill ID or order key';
                }
                final billPattern = RegExp(r'^[a-z]+(-[a-z]+){2,3}$'); // 3 or 4 words
                final orderKeyPattern = RegExp(r'^[a-zA-Z0-9]{4,6}$'); // 4-6 chars
                if (!billPattern.hasMatch(v.trim()) && !orderKeyPattern.hasMatch(v.trim())) {
                  return 'Enter a valid bill ID (3-4 words) or short order key (4-6 chars)';
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
  // Removed unused _OrderDialog class
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

class _OrderDialog extends StatelessWidget {
  final Order order;
  final VoidCallback onClose;

  const _OrderDialog({required this.order, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Order Details', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order ID: ${order.id}'),
          Text('Customer: ${order.customerName}'),
          Text('Items: ${order.items.join(", ")}'),
          Text('Payment Status: ${order.paymentStatus}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onClose,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
