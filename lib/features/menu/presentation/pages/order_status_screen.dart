import 'package:chiya_sathi/features/menu/presentation/providers/order_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderStatusScreen extends ConsumerStatefulWidget {
  const OrderStatusScreen({super.key});

  @override
  ConsumerState<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends ConsumerState<OrderStatusScreen> {
  @override
  void dispose() {
    // Keep polling even when navigating away — it will auto-stop on served/cancelled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: Text(
          'Order Status',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.orange.shade700),
            onPressed: () =>
                ref.read(orderProvider.notifier).refreshStatus(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Status icon
              _StatusIcon(status: order.status),
              const SizedBox(height: 24),
              // Status text
              Text(
                _statusTitle(order.status),
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _statusSubtitle(order.status),
                style: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              // Step indicator
              _StepIndicator(status: order.status),
              const SizedBox(height: 28),
              // Table info
              if (order.tableId != null)
                Builder(builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.blue.shade900.withAlpha(80) : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.table_restaurant,
                            size: 18, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          order.tableId!,
                          style: TextStyle(
                            fontFamily: 'OpenSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 20),
              // Order summary card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontFamily: 'OpenSans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: order.items.length,
                          itemBuilder: (context, index) {
                            final item = order.items[index];
                            final canRemove =
                                order.status == OrderStatus.pending;

                            final child = Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      '${item.menuItem.name} x${item.quantity}',
                                      style: const TextStyle(
                                        fontFamily: 'OpenSans',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${item.totalPrice.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontFamily: 'OpenSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (!canRemove) return child;

                            return Dismissible(
                              key: ValueKey(item.menuItem.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.delete_outline,
                                    color: Colors.white, size: 20),
                              ),
                              confirmDismiss: (_) async {
                                if (order.items.length == 1) {
                                  // Last item — confirm full cancel
                                  return await _confirmCancelOrder(
                                      context);
                                }
                                return true;
                              },
                              onDismissed: (_) async {
                                final success = await ref
                                    .read(orderProvider.notifier)
                                    .removeItem(item.menuItem.id);
                                if (!success && context.mounted) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Failed to remove item'),
                                    ),
                                  );
                                }
                              },
                              child: child,
                            );
                          },
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rs. ${order.totalAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontFamily: 'OpenSans',
                              fontSize: 16,
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
              const SizedBox(height: 16),
              // "Order More" button — visible while order is pending or preparing
              if (order.status == OrderStatus.pending ||
                  order.status == OrderStatus.preparing)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/dashboard',
                        (route) => false,
                        arguments: {'tab': 1},
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart_rounded),
                    label: const Text(
                      'Order More',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange.shade700,
                      side: BorderSide(color: Colors.orange.shade400, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Cancel Order button — only when pending
              if (order.status == OrderStatus.pending)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _handleCancelOrder(context, ref),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text(
                      'Cancel Order',
                      style: TextStyle(
                        fontFamily: 'OpenSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              // Back to home button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/dashboard',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.status == OrderStatus.ready
                        ? Colors.green
                        : Colors.orange.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    order.status == OrderStatus.ready
                        ? 'Pick Up Your Order!'
                        : 'Back to Home',
                    style: const TextStyle(
                      fontFamily: 'OpenSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _statusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.none:
        return 'No active order';
      case OrderStatus.pending:
        return 'Order Placed!';
      case OrderStatus.preparing:
        return 'Being Prepared';
      case OrderStatus.ready:
        return 'Ready for Pickup!';
      case OrderStatus.served:
        return 'Order Served';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
    }
  }

  String _statusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.none:
        return '';
      case OrderStatus.pending:
        return 'Waiting for the shop to accept your order...';
      case OrderStatus.preparing:
        return 'Your order is being prepared. Sit tight!';
      case OrderStatus.ready:
        return 'Your items are ready! Head to the counter.';
      case OrderStatus.served:
        return 'Enjoy your meal!';
      case OrderStatus.cancelled:
        return 'Sorry, your order was cancelled.';
    }
  }

  Future<bool> _confirmCancelOrder(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(
              'Cancel Order?',
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontWeight: FontWeight.w700,
              ),
            ),
            content: const Text(
              'Removing the last item will cancel the entire order. Continue?',
              style: TextStyle(fontFamily: 'OpenSans'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Cancel Order'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _handleCancelOrder(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Cancel Order?',
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this order?',
          style: TextStyle(fontFamily: 'OpenSans'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No, Keep It'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(orderProvider.notifier).cancelOrder();
      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to cancel order')),
          );
        }
      }
    }
  }
}

// ── Status Icon ────────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final OrderStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (status) {
      case OrderStatus.none:
        icon = Icons.receipt_long;
        color = Colors.grey;
        break;
      case OrderStatus.pending:
        icon = Icons.hourglass_top_rounded;
        color = Colors.orange;
        break;
      case OrderStatus.preparing:
        icon = Icons.restaurant;
        color = Colors.blue;
        break;
      case OrderStatus.ready:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case OrderStatus.served:
        icon = Icons.thumb_up;
        color = Colors.green;
        break;
      case OrderStatus.cancelled:
        icon = Icons.cancel;
        color = Colors.red;
        break;
    }
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 50, color: color),
    );
  }
}

// ── Step Indicator ─────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final OrderStatus status;
  const _StepIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final steps = ['Placed', 'Accepted', 'Ready'];
    int activeIndex;
    switch (status) {
      case OrderStatus.pending:
        activeIndex = 0;
        break;
      case OrderStatus.preparing:
        activeIndex = 1;
        break;
      case OrderStatus.ready:
      case OrderStatus.served:
        activeIndex = 2;
        break;
      default:
        activeIndex = -1;
    }

    if (status == OrderStatus.cancelled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          'ORDER CANCELLED',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.red.shade700,
            letterSpacing: 1,
          ),
        ),
      );
    }

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // connector line
          final stepBefore = i ~/ 2;
          final done = stepBefore < activeIndex;
          return Expanded(
            child: Container(
              height: 3,
              color: done ? Colors.green : Colors.grey.shade300,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final done = stepIndex <= activeIndex;
        final isCurrent = stepIndex == activeIndex;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done ? Colors.green : Colors.grey.shade200,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: Colors.green.shade300, width: 3)
                    : null,
              ),
              child: Icon(
                done ? Icons.check : Icons.circle_outlined,
                size: 18,
                color: done ? Colors.white : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              steps[stepIndex],
              style: TextStyle(
                fontFamily: 'OpenSans',
                fontSize: 11,
                fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                color: done ? Colors.green.shade700 : Colors.grey.shade500,
              ),
            ),
          ],
        );
      }),
    );
  }
}
