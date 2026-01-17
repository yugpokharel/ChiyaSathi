import '../../domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;

  const AuthApiModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": fullName,
      "username": username,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'],
      fullName: json['name'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      password: json['password'],
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber, userName: '',
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.id,
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
    );
  }
}
