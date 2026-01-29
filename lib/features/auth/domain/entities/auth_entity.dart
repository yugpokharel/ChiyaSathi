import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? token;

  const AuthEntity({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.token,
  });

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
    return AuthEntity(
      id: json['_id'] ?? json['id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      token: json['token'],
    );
  }

  @override
  List<Object?> get props =>
      [id, fullName, username, email, phoneNumber, token];
}
