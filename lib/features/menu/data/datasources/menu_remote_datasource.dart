import 'dart:convert';
import 'package:chiya_sathi/core/error/exception.dart';
import 'package:http/http.dart' as http;

abstract class MenuRemoteDatasource {
  Future<List<Map<String, dynamic>>> getMenuItems({required String token});

  Future<Map<String, dynamic>> addMenuItem({
    required String token,
    required String name,
    required double price,
    required String category,
    String? image,
  });

  Future<Map<String, dynamic>> updateMenuItem({
    required String token,
    required String itemId,
    required Map<String, dynamic> updates,
  });

  Future<void> deleteMenuItem({
    required String token,
    required String itemId,
  });
}

class MenuRemoteDatasourceImpl implements MenuRemoteDatasource {
  final http.Client client;
  static const String baseUrl = "http://192.168.1.5:5000/api";

  MenuRemoteDatasourceImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> getMenuItems({
    required String token,
  }) async {
    final response = await client.get(
      Uri.parse('$baseUrl/menu'),
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
          message: data['message'] ?? 'Failed to fetch menu');
    }
  }

  @override
  Future<Map<String, dynamic>> addMenuItem({
    required String token,
    required String name,
    required double price,
    required String category,
    String? image,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'price': price,
      'category': category,
    };
    if (image != null) body['image'] = image;

    final response = await client
        .post(
          Uri.parse('$baseUrl/menu'),
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
          message: data['message'] ?? 'Failed to add menu item');
    }
  }

  @override
  Future<Map<String, dynamic>> updateMenuItem({
    required String token,
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    final response = await client
        .put(
          Uri.parse('$baseUrl/menu/$itemId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(updates),
        )
        .timeout(const Duration(seconds: 10));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      return data['data'] ?? data;
    } else {
      throw ServerException(
          message: data['message'] ?? 'Failed to update menu item');
    }
  }

  @override
  Future<void> deleteMenuItem({
    required String token,
    required String itemId,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/menu/$itemId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode != 200 && response.statusCode != 204) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      throw ServerException(
          message: data['message'] ?? 'Failed to delete menu item');
    }
  }
}
