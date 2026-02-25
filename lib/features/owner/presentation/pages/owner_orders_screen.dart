import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/owner/presentation/providers/shop_orders_provider.dart';

class OwnerOrdersScreen extends ConsumerStatefulWidget {
  const OwnerOrdersScreen({super.key});

  @override
  ConsumerState<OwnerOrdersScreen> createState() => _OwnerOrdersScreenState();
}

class _OwnerOrdersScreenState extends ConsumerState<OwnerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = ref.watch(shopOrdersProvider);

    final pending =
        allOrders.where((o) => o.status == ShopOrderStatus.pending).toList();
    final preparing =
        allOrders.where((o) => o.status == ShopOrderStatus.preparing).toList();
    final ready =
        allOrders.where((o) => o.status == ShopOrderStatus.ready).toList();
    final completed = allOrders
        .where((o) =>
            o.status == ShopOrderStatus.served ||
            o.status == ShopOrderStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.orange.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.orange.shade700,
          indicatorWeight: 3,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: [
            Tab(text: 'Pending (${pending.length})'),
            Tab(text: 'Preparing (${preparing.length})'),
            Tab(text: 'Ready (${ready.length})'),
            Tab(text: 'History (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OrderList(
            orders: pending,
            emptyIcon: Icons.pending_actions,
            emptyText: 'No pending orders',
            type: _OrderType.pending,
          ),
          _OrderList(
            orders: preparing,
            emptyIcon: Icons.soup_kitchen,
            emptyText: 'Nothing being prepared',
            type: _OrderType.preparing,
          ),
          _OrderList(
            orders: ready,
            emptyIcon: Icons.check_circle_outline,
            emptyText: 'No orders ready',
            type: _OrderType.ready,
          ),
          _OrderList(
            orders: completed,
            emptyIcon: Icons.history,
            emptyText: 'No order history yet',
            type: _OrderType.history,
          ),
        ],
      ),
    );
  }
}

enum _OrderType { pending, preparing, ready, history }

class _OrderList extends ConsumerWidget {
  final List<ShopOrder> orders;
  final IconData emptyIcon;
  final String emptyText;
  final _OrderType type;

  const _OrderList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyText,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              emptyText,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order, type: type);
      },
    );
  }
}

class _OrderCard extends ConsumerWidget {
  final ShopOrder order;
  final _OrderType type;

  const _OrderCard({required this.order, required this.type});

  Color get _statusColor {
    switch (order.status) {
      case ShopOrderStatus.pending:
        return Colors.orange;
      case ShopOrderStatus.preparing:
        return Colors.blue;
      case ShopOrderStatus.ready:
        return Colors.green;
      case ShopOrderStatus.served:
        return Colors.teal;
      case ShopOrderStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(shopOrdersProvider.notifier);
    final timeAgo = _formatTimeAgo(order.orderedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.id,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.table_bar, size: 15, color: Colors.grey.shade500),
                const SizedBox(width: 3),
                Text(
                  'Table ${order.tableId}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                const SizedBox(width: 3),
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: order.items
                  .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.menuItem.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border:
                  Border(top: BorderSide(color: Colors.grey.shade100)),
            ),
            child: Row(
              children: [
                Text(
                  'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                ..._buildActions(context, notifier),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActions(
      BuildContext context, ShopOrdersNotifier notifier) {
    switch (type) {
      case _OrderType.pending:
        return [
          _SmallActionBtn(
            label: 'Decline',
            color: Colors.red,
            onTap: () => _confirmAction(
              context,
              'Decline Order?',
              'This will cancel ${order.id}.',
              () => notifier.cancelOrder(order.id),
            ),
          ),
          const SizedBox(width: 8),
          _SmallActionBtn(
            label: 'Accept',
            color: Colors.green,
            filled: true,
            onTap: () => notifier.acceptOrder(order.id),
          ),
        ];
      case _OrderType.preparing:
        return [
          _SmallActionBtn(
            label: 'Mark Ready',
            color: Colors.green,
            filled: true,
            onTap: () => notifier.markReady(order.id),
          ),
        ];
      case _OrderType.ready:
        return [
          _SmallActionBtn(
            label: 'Served',
            color: Colors.teal,
            filled: true,
            onTap: () => notifier.markServed(order.id),
          ),
        ];
      case _OrderType.history:
        return [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              order.statusLabel,
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _confirmAction(
              context,
              'Delete Order?',
              'Remove ${order.id} from history?',
              () => notifier.deleteOrder(order.id),
            ),
            child: Icon(Icons.delete_outline,
                size: 20, color: Colors.red.shade300),
          ),
        ];
    }
  }

  void _confirmAction(
    BuildContext context,
    String title,
    String content,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            child: Text('Confirm',
                style: TextStyle(
                    color: Colors.red.shade500,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _SmallActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _SmallActionBtn({
    required this.label,
    required this.color,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: filled ? null : Border.all(color: color),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
