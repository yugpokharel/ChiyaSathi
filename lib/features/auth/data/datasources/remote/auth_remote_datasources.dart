import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRemoteDatasource {
  Future<String> login(String email, String password);

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String phoneNumber,
  });

  Future<AuthEntity> getCurrentUser(String token);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;

  static const String baseUrl = "http://localhost:5000/api";

  AuthRemoteDatasourceImpl({required this.client});

  @override
  Future<String> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'] ?? data['data']?['token'];
      if (token == null) {
        throw Exception('Token not found in response');
      }
      return token;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String phoneNumber,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'fullName': fullName,
        'username': username,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Signup failed');
    }
  }

  @override
  Future<AuthEntity> getCurrentUser(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthEntity.fromJson(data['data']);
    } else {
      throw Exception('Failed to get user profile');
    }
  }
}
