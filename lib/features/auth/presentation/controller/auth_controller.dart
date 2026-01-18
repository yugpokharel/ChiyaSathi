import 'package:chiya_sathi/features/auth/data/repositories/auth_repository.dart';
import 'package:chiya_sathi/features/auth/presentation/pages/signup_screen.dart';
import 'package:flutter/material.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository repository;

  AuthController(this.repository);

  bool isLoading = false;

  Future<void> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.login(email, password);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> SignupScreen(String email, String password, String confirmPassword) async {
    isLoading = true;
    notifyListeners();

    try {
      await repository.SignupScreen(email, password, confirmPassword, phoneNumber, );
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}