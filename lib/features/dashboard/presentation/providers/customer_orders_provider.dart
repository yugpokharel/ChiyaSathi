import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chiya_sathi/core/constants/hive_table_constants.dart';
import 'package:chiya_sathi/features/owner/data/datasources/order_remote_datasource.dart';
import 'package:chiya_sathi/features/owner/presentation/providers/shop_orders_provider.dart';

class CustomerOrdersState {
  final List<ShopOrder> orders;
  final bool isLoading;
  final String? error;

  const CustomerOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerOrdersState copyWith({
    List<ShopOrder>? orders,
    bool? isLoading,
    String? error,
  }) {
    return CustomerOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CustomerOrdersNotifier extends StateNotifier<CustomerOrdersState> {
  final OrderRemoteDatasource _remote;

  CustomerOrdersNotifier(this._remote) : super(const CustomerOrdersState());

  String? get _token {
    final box = Hive.box(HiveTableConstants.authBox);
    return box.get('auth_token') as String?;
  }

  Future<void> fetchOrders() async {
    final token = _token;
    if (token == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final list = await _remote.getOrders(token: token);
      final orders = list.map((json) => ShopOrder.fromJson(json)).toList()
        ..sort((a, b) => b.orderedAt.compareTo(a.orderedAt));
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load orders',
      );
    }
  }
}

final customerOrdersProvider =
    StateNotifierProvider<CustomerOrdersNotifier, CustomerOrdersState>((ref) {
  final datasource = ref.watch(orderRemoteDatasourceProvider);
  return CustomerOrdersNotifier(datasource);
});
