import '../../domain/entities/auth_entity.dart';

class AuthApiModel {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? profilePicture;

  const AuthApiModel({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": fullName,
      "username": username,
      "email": email,
      "phoneNumber": phoneNumber,
      "password": password,
      "profilePicture": profilePicture,
    };
  }

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'],
      fullName: json['name'],
      username: json['username'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profilePicture: json['profilePicture'],
      password: json['password'],
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      id: id,
      fullName: fullName,
      username: username,
      email: email,
      phoneNumber: phoneNumber,
      token: null,
      profilePicture: profilePicture,
      password: password,
    );
  }

  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.id,
      fullName: entity.fullName,
      username: entity.username,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      password: entity.password,
    );
  }
}
