import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/core/services/notification_service.dart';
import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';
import 'package:chiya_sathi/features/owner/data/datasources/order_remote_datasource.dart';
import 'package:chiya_sathi/features/owner/presentation/providers/shop_orders_provider.dart';

enum OrderStatus { none, pending, preparing, ready, served, cancelled }

OrderStatus _fromString(String s) {
  switch (s.toLowerCase()) {
    case 'pending':
      return OrderStatus.pending;
    case 'preparing':
      return OrderStatus.preparing;
    case 'ready':
      return OrderStatus.ready;
    case 'served':
      return OrderStatus.served;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.pending;
  }
}

class OrderState {
  final OrderStatus status;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime? orderedAt;
  final String? orderId;
  final String? tableId;

  OrderState({
    this.status = OrderStatus.none,
    this.items = const [],
    this.totalAmount = 0,
    this.orderedAt,
    this.orderId,
    this.tableId,
  });

  bool get hasActiveOrder =>
      status != OrderStatus.none &&
      status != OrderStatus.served &&
      status != OrderStatus.cancelled;

  String get statusLabel {
    switch (status) {
      case OrderStatus.none:
        return '';
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready to Pickup!';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  OrderState copyWith({
    OrderStatus? status,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderedAt,
    String? orderId,
    String? tableId,
  }) {
    return OrderState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderedAt: orderedAt ?? this.orderedAt,
      orderId: orderId ?? this.orderId,
      tableId: tableId ?? this.tableId,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  final OrderRemoteDatasource _remote;
  Timer? _pollTimer;

  OrderNotifier(this._remote) : super(OrderState());

  String? get _token {
    final box = Hive.box(HiveTableConstants.authBox);
    return box.get('auth_token') as String?;
  }

  void placeOrder(List<CartItem> items, double totalAmount,
      {String? orderId, String? tableId}) {
    state = OrderState(
      status: OrderStatus.pending,
      items: List.from(items),
      totalAmount: totalAmount,
      orderedAt: DateTime.now(),
      orderId: orderId,
      tableId: tableId,
    );
    if (orderId != null) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _pollOrderStatus();
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _pollOrderStatus() async {
    final orderId = state.orderId;
    final token = _token;
    if (orderId == null || token == null) return;

    try {
      final data = await _remote.getOrderById(
        token: token,
        orderId: orderId,
      );
      final newStatus = _fromString(data['status'] ?? 'pending');

      if (newStatus != state.status) {
        final oldStatus = state.status;
        state = state.copyWith(status: newStatus);

        // Notify customer of status changes
        if (newStatus == OrderStatus.preparing &&
            oldStatus == OrderStatus.pending) {
          NotificationService().showOrderNotification(
            title: 'Order Accepted! ☕',
            body: 'Your order is now being prepared.',
          );
        } else if (newStatus == OrderStatus.ready) {
          NotificationService().showOrderNotification(
            title: 'Order Ready! 🎉',
            body: 'Your order is ready for pickup!',
          );
        } else if (newStatus == OrderStatus.cancelled) {
          NotificationService().showOrderNotification(
            title: 'Order Cancelled',
            body: 'Your order has been cancelled.',
          );
          stopPolling();
        } else if (newStatus == OrderStatus.served) {
          stopPolling();
        }
      }
    } catch (_) {
      // Network error — skip this poll cycle
    }
  }

  /// Add more items to the existing active order via PUT /api/orders/:id.
  /// Returns null on success, or an error message string on failure.
  Future<String?> addItemsToOrder(List<CartItem> newItems, double additionalAmount) async {
    final orderId = state.orderId;
    final token = _token;
    if (orderId == null) {
      return 'No active order found. Please place a new order.';
    }
    if (token == null) {
      return 'Authentication token missing. Please log in again.';
    }

    // Merge existing + new items
    final merged = <String, CartItem>{};
    for (final item in state.items) {
      merged[item.menuItem.id] = item;
    }
    for (final item in newItems) {
      if (merged.containsKey(item.menuItem.id)) {
        final existing = merged[item.menuItem.id]!;
        merged[item.menuItem.id] = CartItem(
          menuItem: existing.menuItem,
          quantity: existing.quantity + item.quantity,
        );
      } else {
        merged[item.menuItem.id] = item;
      }
    }

    final mergedList = merged.values.toList();
    final newTotal = mergedList.fold<double>(0, (sum, i) => sum + i.totalPrice);

    try {
      final itemsJson = mergedList
          .map((ci) => {
                'menuItemId': ci.menuItem.id,
                'name': ci.menuItem.name,
                'price': ci.menuItem.price,
                'quantity': ci.quantity,
                'category': ci.menuItem.category,
              })
          .toList();

      await _remote.addItemsToOrder(
        token: token,
        orderId: orderId,
        items: itemsJson,
        totalAmount: newTotal,
      );

      state = state.copyWith(items: mergedList, totalAmount: newTotal);
      return null; // success
    } catch (e) {
      debugPrint('[addItemsToOrder] Error: $e');
      return e.toString();
    }
  }

  /// Save edited items (modified quantities, removed items) via PUT.
  /// Returns null on success, or an error message on failure.
  Future<String?> saveEditedItems(List<CartItem> editedItems) async {
    final orderId = state.orderId;
    final token = _token;
    if (orderId == null || token == null) return 'Missing order or token';

    // Filter out items with quantity <= 0
    final validItems = editedItems.where((i) => i.quantity > 0).toList();

    if (validItems.isEmpty) {
      // All items removed — cancel order
      return await cancelOrder();
    }

    final newTotal = validItems.fold<double>(0, (sum, i) => sum + i.totalPrice);

    try {
      final itemsJson = validItems
          .map((ci) => {
                'menuItemId': ci.menuItem.id,
                'name': ci.menuItem.name,
                'price': ci.menuItem.price,
                'quantity': ci.quantity,
                'category': ci.menuItem.category,
              })
          .toList();

      await _remote.addItemsToOrder(
        token: token,
        orderId: orderId,
        items: itemsJson,
        totalAmount: newTotal,
      );

      state = state.copyWith(items: validItems, totalAmount: newTotal);
      return null;
    } catch (e) {
      debugPrint('[saveEditedItems] Error: $e');
      return e.toString();
    }
  }

  /// Manually refresh (pull-to-refresh)
  Future<void> refreshStatus() async {
    await _pollOrderStatus();
  }

  /// Cancel the entire active order via API.
  /// Returns null on success, or an error message on failure.
  Future<String?> cancelOrder() async {
    final orderId = state.orderId;
    final token = _token;
    if (orderId == null) return 'No active order to cancel';
    if (token == null) return 'Authentication token missing';

    try {
      // Use the general PUT /orders/:id route (customer-accessible)
      // instead of the owner-only /orders/:id/status route.
      final itemsJson = state.items
          .map((ci) => {
                'menuItemId': ci.menuItem.id,
                'name': ci.menuItem.name,
                'price': ci.menuItem.price,
                'quantity': ci.quantity,
                'category': ci.menuItem.category,
              })
          .toList();

      await _remote.addItemsToOrder(
        token: token,
        orderId: orderId,
        items: itemsJson,
        totalAmount: state.totalAmount,
        status: 'cancelled',
      );
      stopPolling();
      state = state.copyWith(status: OrderStatus.cancelled);
      return null; // success
    } catch (e) {
      debugPrint('[cancelOrder] Error: $e');
      return e.toString();
    }
  }

  /// Remove a single item from the active order via PUT /api/orders/:id.
  /// If it's the last item, cancels the order instead.
  Future<bool> removeItem(String menuItemId) async {
    final orderId = state.orderId;
    final token = _token;
    if (orderId == null || token == null) return false;

    final updatedItems =
        state.items.where((i) => i.menuItem.id != menuItemId).toList();

    // If removing the last item, cancel the order
    if (updatedItems.isEmpty) {
      final err = await cancelOrder();
      return err == null;
    }

    final newTotal =
        updatedItems.fold<double>(0, (sum, i) => sum + i.totalPrice);

    try {
      final itemsJson = updatedItems
          .map((ci) => {
                'menuItemId': ci.menuItem.id,
                'name': ci.menuItem.name,
                'price': ci.menuItem.price,
                'quantity': ci.quantity,
                'category': ci.menuItem.category,
              })
          .toList();

      await _remote.addItemsToOrder(
        token: token,
        orderId: orderId,
        items: itemsJson,
        totalAmount: newTotal,
      );

      state = state.copyWith(items: updatedItems, totalAmount: newTotal);
      return true;
    } catch (e) {
      debugPrint('[removeItem] Error: $e');
      return false;
    }
  }

  void clearOrder() {
    stopPolling();
    state = OrderState();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  final datasource = ref.watch(orderRemoteDatasourceProvider);
  return OrderNotifier(datasource);
});
