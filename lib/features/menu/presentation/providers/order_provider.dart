import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';

enum OrderStatus { none, preparing, ready }

class OrderState {
  final OrderStatus status;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime? orderedAt;

  OrderState({
    this.status = OrderStatus.none,
    this.items = const [],
    this.totalAmount = 0,
    this.orderedAt,
  });

  bool get hasActiveOrder => status != OrderStatus.none;

  OrderState copyWith({
    OrderStatus? status,
    List<CartItem>? items,
    double? totalAmount,
    DateTime? orderedAt,
  }) {
    return OrderState(
      status: status ?? this.status,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      orderedAt: orderedAt ?? this.orderedAt,
    );
  }
}

class OrderNotifier extends StateNotifier<OrderState> {
  OrderNotifier() : super(OrderState());

  void placeOrder(List<CartItem> items, double totalAmount) {
    state = OrderState(
      status: OrderStatus.preparing,
      items: List.from(items),
      totalAmount: totalAmount,
      orderedAt: DateTime.now(),
    );
  }

  void clearOrder() {
    state = OrderState();
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier();
});
