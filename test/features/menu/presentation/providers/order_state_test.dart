import 'package:chiya_sathi/features/menu/presentation/providers/order_provider.dart';
import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderState', () {
    test('default state has OrderStatus.none', () {
      final state = OrderState();
      expect(state.status, OrderStatus.none);
      expect(state.items, isEmpty);
      expect(state.totalAmount, 0);
      expect(state.orderedAt, isNull);
      expect(state.orderId, isNull);
      expect(state.tableId, isNull);
    });

    test('hasActiveOrder is false for none status', () {
      final state = OrderState();
      expect(state.hasActiveOrder, false);
    });

    test('hasActiveOrder is true for pending status', () {
      final state = OrderState(status: OrderStatus.pending);
      expect(state.hasActiveOrder, true);
    });

    test('hasActiveOrder is true for preparing status', () {
      final state = OrderState(status: OrderStatus.preparing);
      expect(state.hasActiveOrder, true);
    });

    test('hasActiveOrder is true for ready status', () {
      final state = OrderState(status: OrderStatus.ready);
      expect(state.hasActiveOrder, true);
    });

    test('hasActiveOrder is false for served status', () {
      final state = OrderState(status: OrderStatus.served);
      expect(state.hasActiveOrder, false);
    });

    test('hasActiveOrder is false for cancelled status', () {
      final state = OrderState(status: OrderStatus.cancelled);
      expect(state.hasActiveOrder, false);
    });

    test('statusLabel returns correct labels', () {
      expect(OrderState(status: OrderStatus.none).statusLabel, '');
      expect(OrderState(status: OrderStatus.pending).statusLabel, 'Pending');
      expect(OrderState(status: OrderStatus.preparing).statusLabel, 'Preparing');
      expect(OrderState(status: OrderStatus.ready).statusLabel, 'Ready to Pickup!');
      expect(OrderState(status: OrderStatus.served).statusLabel, 'Served');
      expect(OrderState(status: OrderStatus.cancelled).statusLabel, 'Cancelled');
    });

    test('copyWith returns new state with changed fields', () {
      final item = CartItem(
        menuItem: MenuItem(id: '1', name: 'Tea', price: 50, category: 'Tea'),
      );
      final original = OrderState(
        status: OrderStatus.pending,
        items: [item],
        totalAmount: 50,
        orderId: 'order-1',
      );

      final updated = original.copyWith(
        status: OrderStatus.preparing,
        totalAmount: 100,
      );

      expect(updated.status, OrderStatus.preparing);
      expect(updated.totalAmount, 100);
      expect(updated.items.length, 1); // unchanged
      expect(updated.orderId, 'order-1'); // unchanged
    });
  });
}
