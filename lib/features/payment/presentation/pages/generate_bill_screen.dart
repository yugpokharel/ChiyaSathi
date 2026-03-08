import 'package:chiya_sathi/features/payment/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'show_qr_screen.dart';
import 'dart:math';
import 'package:chiya_sathi/features/payment/presentation/pages/admin_scan_bill_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Short order key generator
String _generateShortOrderKey() {
  final words = [
    'chai', 'latte', 'sathi', 'order', 'table', 'tea', 'bill', 'cup', 'serve', 'fast', 'easy', 'hot', 'cool', 'sweet', 'spice', 'leaf', 'brew', 'sip', 'milk', 'black', 'green', 'gold', 'mint', 'herb', 'fresh', 'bold', 'rich', 'taste', 'blend', 'shop', 'cafe', 'nepal', 'kathmandu', 'pokhara', 'mount', 'hill', 'river', 'cloud', 'sun', 'moon', 'star', 'joy', 'happy', 'smile', 'cheer', 'peace', 'calm', 'zen', 'buzz', 'rush', 'chill', 'relax', 'cozy', 'warm', 'light', 'shine', 'glow', 'pure', 'classic', 'urban', 'local', 'global', 'trend', 'vibe', 'fun', 'yum',
  ];
  final rand = Random();
  return List.generate(3, (_) => words[rand.nextInt(words.length)]).join('-');
}

// Store mapping from short order key to orderId
class OrderKeyStore {
  static final Map<String, String> _keyToOrderId = {};
  static void add(String shortKey, String orderId) {
    _keyToOrderId[shortKey] = orderId;
  }
  static String? getOrderId(String shortKey) => _keyToOrderId[shortKey];
  static Map<String, String> get keyToOrderId => _keyToOrderId;
}

String _generateShortBillId() {
  final words = [
    'chai', 'latte', 'sathi', 'order', 'table', 'tea', 'bill', 'cup', 'serve', 'fast', 'easy', 'hot', 'cool', 'sweet', 'spice', 'leaf', 'brew', 'sip', 'milk', 'black', 'green', 'gold', 'mint', 'herb', 'fresh', 'bold', 'rich', 'taste', 'blend', 'shop', 'cafe', 'nepal', 'kathmandu', 'pokhara', 'mount', 'hill', 'river', 'cloud', 'sun', 'moon', 'star', 'joy', 'happy', 'smile', 'cheer', 'peace', 'calm', 'zen', 'buzz', 'rush', 'chill', 'relax', 'cozy', 'warm', 'light', 'shine', 'glow', 'pure', 'classic', 'urban', 'local', 'global', 'trend', 'vibe', 'fun', 'yum',
    'taste', 'blend', 'leaf', 'brew', 'sip', 'milk', 'black', 'green', 'gold', 'mint', 'herb', 'fresh', 'bold', 'rich', 'shop', 'cafe', 'mount', 'hill', 'river', 'cloud', 'sun', 'moon', 'star', 'joy', 'happy', 'smile', 'cheer', 'peace', 'calm', 'zen', 'buzz', 'rush', 'chill', 'relax', 'cozy', 'warm', 'light', 'shine', 'glow', 'pure', 'classic', 'urban', 'local', 'global', 'trend', 'vibe', 'fun', 'yum'
  ];
  final rand = Random();
  return List.generate(4, (_) => words[rand.nextInt(words.length)]).join('-');
}

Future<Bill> _generateBillFromBackend({
  required String orderId,
  required String tableId,
  required double totalAmount,
}) async {
  await Future.delayed(const Duration(milliseconds: 800));
  final billId = _generateShortBillId();
  final shortOrderKey = _generateShortOrderKey();
  OrderKeyStore.add(shortOrderKey, orderId);
  final bill = Bill(
    billId: billId,
    orderId: orderId,
    tableId: tableId,
    totalAmount: totalAmount,
    generatedAt: DateTime.now(),
    shortOrderKey: shortOrderKey,
  );
  BillStore.addBill(bill); 
  return bill;
}

final billGenerationProvider =
    FutureProvider.family<Bill, _BillParams>((ref, params) async {
  return _generateBillFromBackend(
    orderId: params.orderId,
    tableId: params.tableId,
    totalAmount: params.totalAmount,
  );
});

class _BillParams {
  final String orderId;
  final String tableId;
  final double totalAmount;

  const _BillParams({
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
  });

  @override
  bool operator ==(Object other) =>
      other is _BillParams &&
      other.orderId == orderId &&
      other.tableId == tableId &&
      other.totalAmount == totalAmount;

  @override
  int get hashCode => Object.hash(orderId, tableId, totalAmount);
}

class GenerateBillArgs {
  final String orderId;
  final String tableId;
  final double totalAmount;

  const GenerateBillArgs({
    required this.orderId,
    required this.tableId,
    required this.totalAmount,
  });
}

class GenerateBillScreen extends ConsumerWidget {
  final GenerateBillArgs args;

  const GenerateBillScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = _BillParams(
      orderId: args.orderId,
      tableId: args.tableId,
      totalAmount: args.totalAmount,
    );

    final billAsync = ref.watch(billGenerationProvider(params));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0EB),
      appBar: AppBar(
        title: const Text('Generate Bill'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6B3F1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: billAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF6B3F1A)),
              SizedBox(height: 16),
              Text('Generating bill…', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        error: (err, _) => _ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(billGenerationProvider(params)),
        ),
        data: (bill) => _BillContent(bill: bill),
      ),
    );
  }
}

class _BillContent extends StatelessWidget {
  final Bill bill;

  const _BillContent({required this.bill});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BillCard(bill: bill),
          const SizedBox(height: 12),
          _DetailRow(label: 'Short Order Key', value: bill.shortOrderKey ?? 'N/A'),
          const SizedBox(height: 32),
          _ActionButton(
            label: 'Pay Online',
            icon: Icons.payment_rounded,
            color: const Color(0xFF6B3F1A),
            onPressed: () => _handlePayOnline(context, bill),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            label: 'Show QR',
            icon: Icons.qr_code_2_rounded,
            color: const Color(0xFF3A7D44),
            onPressed: () => _handleShowQr(context, bill),
          ),
        ],
      ),
    );
  }

  void _handlePayOnline(BuildContext context, Bill bill) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Redirecting to payment gateway for bill ${bill.billId}…'),
        backgroundColor: const Color(0xFF6B3F1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleShowQr(BuildContext context, Bill bill) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShowQrScreen(bill: bill)),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;

  const _BillCard({required this.bill});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Color(0xFF6B3F1A), size: 28),
                const SizedBox(width: 12),
                Text('Chiya Sathi', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF6B3F1A))),
              ],
            ),
            const Divider(height: 32),
            _DetailRow(label: 'Bill ID', value: bill.billId),
            const SizedBox(height: 12),
            _DetailRow(label: 'Order ID', value: bill.orderId),
            const SizedBox(height: 12),
            _DetailRow(label: 'Table', value: bill.tableId),
            const SizedBox(height: 12),
            _DetailRow(label: 'Generated At', value: _formatDateTime(bill.generatedAt)),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                Text('Rs. ${bill.totalAmount.toStringAsFixed(2)}', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF6B3F1A), fontSize: 20)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}  ${_pad(dt.hour)}:${_pad(dt.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            Text('Failed to generate bill', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B3F1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<Order>> fetchAllOrders() async {
  final response = await http.get(Uri.parse('https://your-backend.com/api/orders'));
  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Order.fromJson(json)).toList();
  } else {
    throw Exception('Failed to fetch orders');
  }
}

String generateBillKey(String orderId) {
  return 'CS-' + base64Url.encode(utf8.encode(orderId)).substring(0, 6).toUpperCase();
}

Future<Order?> lookupOrderByBillKey(String billKey) async {
  final orders = await fetchAllOrders();
  for (final order in orders) {
    final key = generateBillKey(order.id);
    if (key == billKey) {
      return order;
    }
  }
  return null;
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
