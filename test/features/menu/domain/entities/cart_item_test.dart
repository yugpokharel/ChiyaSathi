import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartItem', () {
    final menuItem = MenuItem(
      id: '1',
      name: 'Milk Tea',
      price: 50.0,
      category: 'Tea',
    );

    test('default quantity should be 1', () {
      final cartItem = CartItem(menuItem: menuItem);
      expect(cartItem.quantity, 1);
    });

    test('totalPrice should be price * quantity', () {
      final cartItem = CartItem(menuItem: menuItem, quantity: 3);
      expect(cartItem.totalPrice, 150.0);
    });

    test('totalPrice with quantity 1 equals menuItem price', () {
      final cartItem = CartItem(menuItem: menuItem);
      expect(cartItem.totalPrice, 50.0);
    });

    test('quantity can be modified', () {
      final cartItem = CartItem(menuItem: menuItem);
      cartItem.quantity = 5;
      expect(cartItem.quantity, 5);
      expect(cartItem.totalPrice, 250.0);
    });
  });
}
