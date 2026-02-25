import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/menu/domain/entities/cart_item.dart';
import 'package:chiya_sathi/features/menu/domain/entities/menu_item.dart';
import 'package:chiya_sathi/features/owner/data/datasources/order_remote_datasource.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:http/http.dart' as http;

enum ShopOrderStatus { pending, preparing, ready, served, cancelled }

ShopOrderStatus _parseStatus(String s) {
  switch (s.toLowerCase()) {
    case 'pending':
      return ShopOrderStatus.pending;
    case 'preparing':
      return ShopOrderStatus.preparing;
    case 'ready':
      return ShopOrderStatus.ready;
    case 'served':
      return ShopOrderStatus.served;
    case 'cancelled':
      return ShopOrderStatus.cancelled;
    default:
      return ShopOrderStatus.pending;
  }
}

String _statusToString(ShopOrderStatus s) {
  switch (s) {
    case ShopOrderStatus.pending:
      return 'pending';
    case ShopOrderStatus.preparing:
      return 'preparing';
    case ShopOrderStatus.ready:
      return 'ready';
    case ShopOrderStatus.served:
      return 'served';
    case ShopOrderStatus.cancelled:
      return 'cancelled';
  }
}

class ShopOrder {
  final String id;
  final String tableId;
  final List<CartItem> items;
  final double totalAmount;
  final ShopOrderStatus status;
  final DateTime orderedAt;
  final String? customerNote;

  ShopOrder({
    required this.id,
    required this.tableId,
    required this.items,
    required this.totalAmount,
    this.status = ShopOrderStatus.pending,
    required this.orderedAt,
    this.customerNote,
  });

  ShopOrder copyWith({
    ShopOrderStatus? status,
    String? customerNote,
  }) {
    return ShopOrder(
      id: id,
      tableId: tableId,
      items: items,
      totalAmount: totalAmount,
      status: status ?? this.status,
      orderedAt: orderedAt,
      customerNote: customerNote ?? this.customerNote,
    );
  }

  String get statusLabel {
    switch (status) {
      case ShopOrderStatus.pending:
        return 'Pending';
      case ShopOrderStatus.preparing:
        return 'Preparing';
      case ShopOrderStatus.ready:
        return 'Ready';
      case ShopOrderStatus.served:
        return 'Served';
      case ShopOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Build from API JSON
  factory ShopOrder.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>? ?? []).map((e) {
      final m = e as Map<String, dynamic>;
      return CartItem(
        menuItem: MenuItem(
          id: m['menuItemId'] ?? '',
          name: m['name'] ?? '',
          price: (m['price'] as num?)?.toDouble() ?? 0,
          category: m['category'] ?? '',
        ),
        quantity: m['quantity'] ?? 1,
      );
    }).toList();

    return ShopOrder(
      id: json['_id'] ?? json['id'] ?? '',
      tableId: json['tableId'] ?? '',
      items: itemsList,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status'] ?? 'pending'),
      orderedAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      customerNote: json['customerNote'],
    );
  }
}

class ShopOrdersNotifier extends StateNotifier<List<ShopOrder>> {
  final OrderRemoteDatasource _remoteDatasource;

  ShopOrdersNotifier(this._remoteDatasource) : super([]);

  String? get _token {
    final box = Hive.box(HiveTableConstants.authBox);
    return box.get('auth_token') as String?;
  }

  /// Fetch all orders from server
  Future<void> fetchOrders() async {
    final token = _token;
    if (token == null) return;

    try {
      final list = await _remoteDatasource.getOrders(token: token);
      state = list.map((json) => ShopOrder.fromJson(json)).toList()
        ..sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
    } catch (_) {
      // silently fail — keep current state
    }
  }

  /// Customer places an order → sends to API
  Future<String?> placeOrder({
    required String tableId,
    required List<CartItem> items,
    required double totalAmount,
    String? customerNote,
  }) async {
    final token = _token;
    if (token == null) return null;

    try {
      final itemsJson = items
          .map((ci) => {
                'menuItemId': ci.menuItem.id,
                'name': ci.menuItem.name,
                'price': ci.menuItem.price,
                'quantity': ci.quantity,
                'category': ci.menuItem.category,
              })
          .toList();

      final data = await _remoteDatasource.placeOrder(
        token: token,
        tableId: tableId,
        items: itemsJson,
        totalAmount: totalAmount,
        customerNote: customerNote,
      );

      final order = ShopOrder.fromJson(data);
      state = [order, ...state];
      return order.id;
    } catch (_) {
      // Fallback: add locally so UI still works
      final localId = 'LOCAL-${DateTime.now().millisecondsSinceEpoch}';
      final order = ShopOrder(
        id: localId,
        tableId: tableId,
        items: List.from(items),
        totalAmount: totalAmount,
        status: ShopOrderStatus.pending,
        orderedAt: DateTime.now(),
      );
      state = [order, ...state];
      return localId;
    }
  }

  /// Owner accepts an order → preparing
  Future<void> acceptOrder(String orderId) async {
    await _updateStatus(orderId, ShopOrderStatus.preparing);
  }

  /// Owner marks order as ready
  Future<void> markReady(String orderId) async {
    await _updateStatus(orderId, ShopOrderStatus.ready);
  }

  /// Owner marks order as served
  Future<void> markServed(String orderId) async {
    await _updateStatus(orderId, ShopOrderStatus.served);
  }

  /// Owner cancels an order
  Future<void> cancelOrder(String orderId) async {
    await _updateStatus(orderId, ShopOrderStatus.cancelled);
  }

  /// Remove an order entirely
  Future<void> deleteOrder(String orderId) async {
    final token = _token;
    if (token != null) {
      try {
        await _remoteDatasource.deleteOrder(token: token, orderId: orderId);
      } catch (_) {}
    }
    state = state.where((o) => o.id != orderId).toList();
  }

  Future<void> _updateStatus(String orderId, ShopOrderStatus newStatus) async {
    // Optimistic update
    state = state.map((o) {
      if (o.id == orderId) return o.copyWith(status: newStatus);
      return o;
    }).toList();

    final token = _token;
    if (token != null) {
      try {
        await _remoteDatasource.updateOrderStatus(
          token: token,
          orderId: orderId,
          status: _statusToString(newStatus),
        );
      } catch (_) {
        // Already updated optimistically
      }
    }
  }

  /// Get active orders (not served or cancelled)
  List<ShopOrder> get activeOrders {
    return state
        .where((o) =>
            o.status != ShopOrderStatus.served &&
            o.status != ShopOrderStatus.cancelled)
        .toList();
  }

  /// Statistics
  int get totalOrdersToday {
    final today = DateTime.now();
    return state
        .where((o) =>
            o.orderedAt.year == today.year &&
            o.orderedAt.month == today.month &&
            o.orderedAt.day == today.day)
        .length;
  }

  double get totalRevenueToday {
    final today = DateTime.now();
    return state
        .where((o) =>
            o.orderedAt.year == today.year &&
            o.orderedAt.month == today.month &&
            o.orderedAt.day == today.day &&
            o.status != ShopOrderStatus.cancelled)
        .fold(0, (sum, o) => sum + o.totalAmount);
  }

  int get pendingCount =>
      state.where((o) => o.status == ShopOrderStatus.pending).length;

  int get preparingCount =>
      state.where((o) => o.status == ShopOrderStatus.preparing).length;
}

final orderRemoteDatasourceProvider = Provider<OrderRemoteDatasource>(
  (ref) => OrderRemoteDatasourceImpl(client: http.Client()),
);

final shopOrdersProvider =
    StateNotifierProvider<ShopOrdersNotifier, List<ShopOrder>>((ref) {
  final datasource = ref.watch(orderRemoteDatasourceProvider);
  return ShopOrdersNotifier(datasource);
});

