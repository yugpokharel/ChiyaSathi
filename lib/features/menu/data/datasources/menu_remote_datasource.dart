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
    String? imagePath,
  });

  Future<Map<String, dynamic>> updateMenuItem({
    required String token,
    required String itemId,
    required Map<String, dynamic> updates,
    String? imagePath,
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
    String? imagePath,
  }) async {
    late http.Response response;

    if (imagePath != null) {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/menu'))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['name'] = name
        ..fields['price'] = price.toString()
        ..fields['category'] = category
        ..files.add(await http.MultipartFile.fromPath('image', imagePath));
      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      response = await http.Response.fromStream(streamed);
    } else {
      response = await client
          .post(
            Uri.parse('$baseUrl/menu'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'name': name,
              'price': price,
              'category': category,
            }),
          )
          .timeout(const Duration(seconds: 10));
    }

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
    String? imagePath,
  }) async {
    late http.Response response;

    if (imagePath != null) {
      final request =
          http.MultipartRequest('PUT', Uri.parse('$baseUrl/menu/$itemId'))
            ..headers['Authorization'] = 'Bearer $token';
      updates.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      request.files
          .add(await http.MultipartFile.fromPath('image', imagePath));
      final streamed =
          await request.send().timeout(const Duration(seconds: 30));
      response = await http.Response.fromStream(streamed);
    } else {
      response = await client
          .put(
            Uri.parse('$baseUrl/menu/$itemId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(updates),
          )
          .timeout(const Duration(seconds: 10));
    }

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
