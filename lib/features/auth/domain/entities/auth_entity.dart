import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? id;
  final String fullName;
  final String username;
  final String email;
  final String phoneNumber;
  final String? password;

  const AuthEntity({
    this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    this.password, required String userName,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        username,
        email,
        phoneNumber,
      ];
}
