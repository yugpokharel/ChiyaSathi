import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String? userName;
  final String email;
  final String? password;
  final String? profileImage;

  const AuthEntity({
    this.userId,
    required this.email,
    this.profileImage,
    this.userName,
    this.password,
  });

  @override
  List<Object?> get props => [email, profileImage, userName, password];
}
