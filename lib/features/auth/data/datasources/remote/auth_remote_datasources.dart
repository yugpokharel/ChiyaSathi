import 'dart:convert';
import 'dart:io';
import 'package:chiya_sathi/core/error/exception.dart';
import 'package:http/http.dart' as http;
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';

abstract class AuthRemoteDatasource {
  Future<Map<String, dynamic>> login(String email, String password);

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String phoneNumber,
    File? profilePicture,
  });

  Future<AuthEntity> getCurrentUser(String token);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final http.Client client;

  static const String baseUrl = "http://192.168.1.5:5000/api"; 

  AuthRemoteDatasourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    ).timeout(const Duration(seconds: 5));

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      final user = data['data']; // Changed from 'user' to 'data'
      if (token == null) {
        throw ServerException(message: 'Token not found in response');
      }
      return {
        'token': token,
        'user': user,
      };
    } else {
      throw ServerException(message: data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String phoneNumber,
    File? profilePicture,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/auth/register'),
    );

    // Add form fields
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['fullName'] = fullName;
    request.fields['username'] = username;
    request.fields['phoneNumber'] = phoneNumber;

    // Add profile picture if provided
    if (profilePicture != null && profilePicture.existsSync()) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePicture',
          profilePicture.path,
        ),
      );
    }

    final response = await request.send().timeout(const Duration(seconds: 5));

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(responseBody);
      throw ServerException(message: data['message'] ?? 'Signup failed');
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
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return AuthEntity.fromJson(data['data']);
    } else {
      throw Exception('Failed to get user profile');
    }
  }
}
