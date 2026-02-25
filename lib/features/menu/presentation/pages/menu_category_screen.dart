import 'package:chiya_sathi/core/services/notification_service.dart';
import 'package:chiya_sathi/features/menu/data/repositories/menu_repository.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/cart_provider.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/order_provider.dart';
import 'package:chiya_sathi/features/owner/presentation/providers/shop_orders_provider.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MenuCategoryScreen extends ConsumerWidget {
  final String category;
  const MenuCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuItems = MenuRepository().getMenuItemsByCategory(category);
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final totalAmount = cartNotifier.totalAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        backgroundColor: Colors.orange.shade400,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final quantity = cartNotifier.getQuantity(item.id);
          return _MenuItemCard(
            item: item,
            quantity: quantity,
            onAdd: () => cartNotifier.addItem(item),
            onRemove: () => cartNotifier.removeItem(item),
          );
        },
      ),
      bottomSheet: cartItems.isNotEmpty
          ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () async {
                  // Get table ID
                  final box = Hive.box(HiveTableConstants.authBox);
                  final tableId = box.get('tableId', defaultValue: '?');

                  // Place order in customer's local state
                  ref.read(orderProvider.notifier).placeOrder(
                        cartItems,
                        totalAmount,
                      );

                  // Place order via API (visible to owner)
                  await ref.read(shopOrdersProvider.notifier).placeOrder(
                        tableId: tableId,
                        items: cartItems,
                        totalAmount: totalAmount,
                      );

                  // Clear the cart
                  cartNotifier.clearCart();

                  // Show notification
                  NotificationService().showOrderNotification(
                    title: 'Chiya Sathi',
                    body: 'Your order is being prepared! Please wait.',
                  );

                  // Navigate to order status
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/order_status',
                      (route) => false,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Proceed  •  Rs. ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _MenuItemCard({
    required this.item,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.image ?? 'assets/images/placeholder.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.fastfood, color: Colors.grey.shade400),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.remove_circle_outline,
                      color: quantity > 0
                          ? Colors.orange.shade700
                          : Colors.grey.shade400,
                    ),
                    onPressed: quantity > 0 ? onRemove : null,
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: Colors.orange.shade700,
                    ),
                    onPressed: onAdd,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
