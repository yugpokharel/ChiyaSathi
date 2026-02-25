import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;
  final String? token;
  final String? profilePicture;
  final String? role;

  const AuthEntity({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password,
    this.token,
    this.profilePicture,
    this.role,
  });

  factory AuthEntity.fromJson(Map<String, dynamic> json) {
  return AuthEntity(
    id: json['_id'] ?? json['id'],
    fullName: json['fullName'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    token: json['token'],
    profilePicture: json['profilePicture'],
    role: json['role'],
  );
}

  AuthEntity copyWith({
    String? id,
    String? fullName,
    String? username,
    String? email,
    String? phoneNumber,
    String? password,
    String? token,
    String? profilePicture,
    String? role,
  }) {
    return AuthEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      token: token ?? this.token,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
    );
  }


  @override
  List<Object?> get props =>
      [id, fullName, username, email, phoneNumber, token, profilePicture, role];
}
