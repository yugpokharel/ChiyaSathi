import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem menuItem) {
    final existingIndex =
        state.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (existingIndex >= 0) {
      final updated = [...state];
      updated[existingIndex].quantity++;
      state = updated;
    } else {
      state = [...state, CartItem(menuItem: menuItem)];
    }
  }

  void removeItem(MenuItem menuItem) {
    final existingIndex =
        state.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (existingIndex >= 0) {
      final updated = [...state];
      if (updated[existingIndex].quantity > 1) {
        updated[existingIndex].quantity--;
        state = updated;
      } else {
        updated.removeAt(existingIndex);
        state = updated;
      }
    }
  }

  int getQuantity(String menuItemId) {
    final index = state.indexWhere((item) => item.menuItem.id == menuItemId);
    return index >= 0 ? state[index].quantity : 0;
  }

  double get totalAmount {
    return state.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
