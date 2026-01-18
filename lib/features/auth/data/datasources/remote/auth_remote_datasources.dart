import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chiya_sathi/features/auth/data/models/auth_api_model.dart';

abstract interface class AuthRemoteDatasource {
  Future<String> login(String email, String password);
  Future<void> register(AuthApiModel model);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;
  final String baseUrl = "http://localhost:5000/api";

  AuthRemoteDatasourceImpl({required this.client});

  @override
  Future<String> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['token']['token']; 
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception("Server Error: ${e.toString()}");
    }
  }

  @override
  Future<void> register(AuthApiModel model) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 201) {
        throw Exception(data['message'] ?? 'Signup failed');
      }
    } catch (e) {
      throw Exception("Server Error: ${e.toString()}");
    }
  }
}