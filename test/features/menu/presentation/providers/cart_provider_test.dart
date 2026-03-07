import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/cart_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ProviderContainer container;

  final tea = MenuItem(id: 'tea-1', name: 'Milk Tea', price: 50, category: 'Tea');
  final coffee = MenuItem(id: 'coffee-1', name: 'Latte', price: 160, category: 'Coffee');

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  group('CartNotifier', () {
    test('initial state is empty', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('addItem adds a new item with quantity 1', () {
      container.read(cartProvider.notifier).addItem(tea);
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.menuItem.id, 'tea-1');
      expect(cart.first.quantity, 1);
    });

    test('addItem increments quantity for existing item', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.addItem(tea);
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.quantity, 2);
    });

    test('addItem adds multiple different items', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.addItem(coffee);
      final cart = container.read(cartProvider);
      expect(cart.length, 2);
    });

    test('removeItem decrements quantity', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.addItem(tea); // qty = 2
      notifier.removeItem(tea); // qty = 1
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
      expect(cart.first.quantity, 1);
    });

    test('removeItem removes item when quantity reaches 0', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.removeItem(tea);
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
    });

    test('removeItem does nothing for non-existent item', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.removeItem(coffee); // not in cart
      final cart = container.read(cartProvider);
      expect(cart.length, 1);
    });

    test('getQuantity returns correct quantity', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.addItem(tea);
      expect(notifier.getQuantity('tea-1'), 2);
    });

    test('getQuantity returns 0 for non-existent item', () {
      final notifier = container.read(cartProvider.notifier);
      expect(notifier.getQuantity('unknown'), 0);
    });

    test('totalAmount computes sum correctly', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea); // 50
      notifier.addItem(tea); // 50
      notifier.addItem(coffee); // 160
      expect(notifier.totalAmount, 260.0);
    });

    test('totalAmount is 0 for empty cart', () {
      final notifier = container.read(cartProvider.notifier);
      expect(notifier.totalAmount, 0.0);
    });

    test('clearCart empties the cart', () {
      final notifier = container.read(cartProvider.notifier);
      notifier.addItem(tea);
      notifier.addItem(coffee);
      notifier.clearCart();
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
      expect(notifier.totalAmount, 0.0);
    });
  });
}
