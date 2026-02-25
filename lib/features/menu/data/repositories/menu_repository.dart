import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';

class MenuRepository {
  /// Static fallback menu used when the API is unavailable
  static final List<MenuItem> fallbackItems = [
    // Tea
    MenuItem(id: 'tea-001', name: 'Milk Tea', price: 50, category: 'Tea', image: 'assets/images/tea.jpg'),
    MenuItem(id: 'tea-002', name: 'Lemon Tea', price: 40, category: 'Tea', image: 'assets/images/tea.jpg'),
    MenuItem(id: 'tea-003', name: 'Black Tea', price: 30, category: 'Tea', image: 'assets/images/tea.jpg'),

    // Coffee
    MenuItem(id: 'coffee-001', name: 'Espresso', price: 100, category: 'Coffee', image: 'assets/images/coffee.jpg'),
    MenuItem(id: 'coffee-002', name: 'Cappuccino', price: 150, category: 'Coffee', image: 'assets/images/coffee.jpg'),
    MenuItem(id: 'coffee-003', name: 'Latte', price: 160, category: 'Coffee', image: 'assets/images/coffee.jpg'),

    // Cigarette
    MenuItem(id: 'cig-001', name: 'Shikhar Ice', price: 20, category: 'Cigarette', image: 'assets/images/shikhar_ice.jpg'),
    MenuItem(id: 'cig-002', name: 'Surya', price: 20, category: 'Cigarette', image: 'assets/images/surya.jpg'),
    MenuItem(id: 'cig-003', name: 'Fusion', price: 20, category: 'Cigarette', image: 'assets/images/fusion.jpg'),

    // Snacks
    MenuItem(id: 'snack-001', name: 'Samosa', price: 30, category: 'Snacks', image: 'assets/images/snacks.jpg'),
    MenuItem(id: 'snack-002', name: 'Fries', price: 100, category: 'Snacks', image: 'assets/images/snacks.jpg'),
  ];

  List<MenuItem> getMenuItemsByCategory(String category) {
    return fallbackItems.where((item) => item.category == category).toList();
  }
}
