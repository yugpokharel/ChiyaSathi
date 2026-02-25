import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/menu/data/datasources/menu_remote_datasource.dart';
import 'package:chiya_sathi/features/menu/data/repositories/menu_repository.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';

// ── Datasource provider ────────────────────────────────────────────────────

final menuRemoteDatasourceProvider = Provider<MenuRemoteDatasource>(
  (ref) => MenuRemoteDatasourceImpl(client: http.Client()),
);

// ── Menu state ─────────────────────────────────────────────────────────────

class MenuState {
  final List<MenuItem> items;
  final bool isLoading;
  final String? error;

  const MenuState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  MenuState copyWith({
    List<MenuItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return MenuState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<MenuItem> byCategory(String category) {
    return items.where((i) => i.category == category).toList();
  }

  List<String> get categories {
    final cats = items.map((i) => i.category).toSet().toList();
    // Preserve a preferred order, then append any extras
    const preferred = ['Tea', 'Coffee', 'Cigarette', 'Snacks'];
    final ordered = <String>[];
    for (final c in preferred) {
      if (cats.contains(c)) ordered.add(c);
    }
    for (final c in cats) {
      if (!ordered.contains(c)) ordered.add(c);
    }
    return ordered;
  }
}

// ── Notifier ───────────────────────────────────────────────────────────────

class MenuNotifier extends StateNotifier<MenuState> {
  final MenuRemoteDatasource _remote;

  MenuNotifier(this._remote) : super(const MenuState());

  String? get _token {
    final box = Hive.box(HiveTableConstants.authBox);
    return box.get('auth_token') as String?;
  }

  /// Fetch menu items from API; fall back to static data
  Future<void> fetchMenu() async {
    // Only show loading spinner if we have no items yet
    if (state.items.isEmpty) {
      state = state.copyWith(isLoading: true, error: null);
    }

    final token = _token;
    if (token == null) {
      // No token → use static fallback
      state = MenuState(items: MenuRepository.fallbackItems);
      return;
    }

    try {
      final list = await _remote.getMenuItems(token: token);
      final items = list.map((j) => MenuItem.fromJson(j)).toList();

      if (items.isEmpty) {
        // API returned empty → keep current items or use fallback
        if (state.items.isEmpty) {
          state = MenuState(items: MenuRepository.fallbackItems);
        }
      } else {
        state = MenuState(items: items);
      }
    } catch (_) {
      // Network/API error → use fallback only if we have nothing
      if (state.items.isEmpty) {
        state = MenuState(items: MenuRepository.fallbackItems);
      }
      // Otherwise keep current items — don't wipe them on a failed refresh
    }
  }

  /// Owner adds a new menu item
  Future<bool> addItem({
    required String name,
    required double price,
    required String category,
    String? imagePath,
  }) async {
    final token = _token;
    if (token == null) return false;

    try {
      final data = await _remote.addMenuItem(
        token: token,
        name: name,
        price: price,
        category: category,
        imagePath: imagePath,
      );
      final item = MenuItem.fromJson(data);
      state = state.copyWith(items: [...state.items, item]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Owner updates a menu item
  Future<bool> updateItem({
    required String itemId,
    String? name,
    double? price,
    String? category,
    String? imagePath,
  }) async {
    final token = _token;
    if (token == null) return false;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (price != null) updates['price'] = price;
    if (category != null) updates['category'] = category;

    try {
      final data = await _remote.updateMenuItem(
        token: token,
        itemId: itemId,
        updates: updates,
        imagePath: imagePath,
      );
      final updated = MenuItem.fromJson(data);
      state = state.copyWith(
        items: state.items.map((i) => i.id == itemId ? updated : i).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Owner deletes a menu item
  Future<bool> deleteItem(String itemId) async {
    final token = _token;
    if (token == null) return false;

    try {
      await _remote.deleteMenuItem(token: token, itemId: itemId);
      state = state.copyWith(
        items: state.items.where((i) => i.id != itemId).toList(),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

// ── Provider ───────────────────────────────────────────────────────────────

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) {
  final datasource = ref.watch(menuRemoteDatasourceProvider);
  return MenuNotifier(datasource);
});
