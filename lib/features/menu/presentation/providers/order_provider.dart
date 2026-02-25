import 'dart:async';
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
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
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

  /// Manually refresh (pull-to-refresh)
  Future<void> refreshStatus() async {
    await _pollOrderStatus();
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
