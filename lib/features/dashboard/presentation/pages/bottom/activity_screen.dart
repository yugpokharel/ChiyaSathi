import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/dashboard/presentation/providers/customer_orders_provider.dart';
import 'package:chiya_sathi/features/owner/presentation/providers/shop_orders_provider.dart';
import 'package:intl/intl.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(customerOrdersProvider.notifier).fetchOrders(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerOrdersProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      child: RefreshIndicator(
        color: Colors.orange,
        onRefresh: () =>
            ref.read(customerOrdersProvider.notifier).fetchOrders(),
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long,
                          color: Colors.orange.shade700, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Log',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        Text(
                          'Your order history',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Loading ──
            if (state.isLoading && state.orders.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                ),
              ),

            // ── Error ──
            if (state.error != null && state.orders.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded,
                          size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        state.error!,
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: () => ref
                            .read(customerOrdersProvider.notifier)
                            .fetchOrders(),
                        icon: const Icon(Icons.refresh, color: Colors.orange),
                        label: const Text('Retry',
                            style: TextStyle(color: Colors.orange)),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Empty ──
            if (!state.isLoading &&
                state.error == null &&
                state.orders.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your order history will appear here',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── Order List ──
            if (state.orders.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final order = state.orders[index];
                      return _OrderCard(order: order);
                    },
                    childCount: state.orders.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Order Card ─────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final ShopOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(order.status);
    final statusIcon = _statusIcon(order.status);
    final dateStr = DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showOrderDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: status chip + date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            order.statusLabel,
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Items preview
                ...order.items.take(3).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.menuItem.name,
                                style: TextStyle(
                                  fontFamily: 'OpenSans',
                                  fontSize: 13,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontFamily: 'OpenSans',
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                if (order.items.length > 3)
                  Text(
                    '+${order.items.length - 3} more items',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade500,
                    ),
                  ),
                const SizedBox(height: 10),
                // Bottom row: table + total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.table_restaurant,
                            size: 14,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(
                          order.tableId,
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 12,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateStr =
        DateFormat('EEEE, MMM dd, yyyy • hh:mm a').format(order.orderedAt);
    final statusColor = _statusColor(order.status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Title + status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Details',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.statusLabel,
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dateStr,
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.table_restaurant,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    order.tableId,
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              const SizedBox(height: 8),
              // Items list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) {
                    final item = order.items[i];
                    return Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.orange.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.quantity}',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.menuItem.name,
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 14,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        Text(
                          'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
              const SizedBox(height: 8),
              // Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(ShopOrderStatus status) {
    switch (status) {
      case ShopOrderStatus.pending:
        return Colors.orange;
      case ShopOrderStatus.preparing:
        return Colors.blue;
      case ShopOrderStatus.ready:
        return Colors.green;
      case ShopOrderStatus.served:
        return Colors.green.shade700;
      case ShopOrderStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _statusIcon(ShopOrderStatus status) {
    switch (status) {
      case ShopOrderStatus.pending:
        return Icons.hourglass_top_rounded;
      case ShopOrderStatus.preparing:
        return Icons.restaurant;
      case ShopOrderStatus.ready:
        return Icons.check_circle;
      case ShopOrderStatus.served:
        return Icons.thumb_up;
      case ShopOrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}
