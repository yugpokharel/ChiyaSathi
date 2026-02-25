import 'dart:convert';
import 'package:chiya_sathi/core/error/exception.dart';
import 'package:http/http.dart' as http;

abstract class OrderRemoteDatasource {
  Future<Map<String, dynamic>> placeOrder({
    required String token,
    required String tableId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerNote,
  });

  Future<List<Map<String, dynamic>>> getOrders({required String token});

  Future<Map<String, dynamic>> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  });

  Future<void> deleteOrder({
    required String token,
    required String orderId,
  });

  Future<Map<String, dynamic>> getOrderById({
    required String token,
    required String orderId,
  });
}

class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  final http.Client client;
  static const String baseUrl = "http://192.168.1.5:5000/api";

  OrderRemoteDatasourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> placeOrder({
    required String token,
    required String tableId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    String? customerNote,
  }) async {
    final body = <String, dynamic>{
      'tableId': tableId,
      'items': items,
      'totalAmount': totalAmount,
    };
    if (customerNote != null && customerNote.isNotEmpty) {
      body['customerNote'] = customerNote;
    }
    final response = await client
        .post(
          Uri.parse('$baseUrl/orders'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 201 || response.statusCode == 200) {
      return data['data'] ?? data;
    } else {
      throw ServerException(
          message: data['message'] ?? 'Failed to place order');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrders({required String token}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/orders'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final list = data['data'] as List<dynamic>? ?? [];
      return list.cast<Map<String, dynamic>>();
    } else {
      throw ServerException(
          message: data['message'] ?? 'Failed to fetch orders');
    }
  }

  @override
  Future<Map<String, dynamic>> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    final response = await client
        .put(
          Uri.parse('$baseUrl/orders/$orderId/status'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({'status': status}),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['data'] ?? data;
    } else {
      throw ServerException(
          message: data['message'] ?? 'Failed to update order status');
    }
  }

  @override
  Future<void> deleteOrder({
    required String token,
    required String orderId,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw ServerException(
          message: data['message'] ?? 'Failed to delete order');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderById({
    required String token,
    required String orderId,
  }) async {
    final response = await client.get(
      Uri.parse('$baseUrl/orders/$orderId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['data'] ?? data;
    } else {
      throw ServerException(
          message: data['message'] ?? 'Failed to fetch order');
    }
  }
}
