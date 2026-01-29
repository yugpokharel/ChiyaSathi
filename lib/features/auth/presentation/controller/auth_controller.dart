import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository repository; // Use the interface type

  AuthController(this.repository);

  bool isLoading = false;

  Future<String?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final result = await repository.login(email, password);

    isLoading = false;
    notifyListeners();

    return result.fold(
      (failure) => failure.message, // Return error message
      (userEntity) => null,         // Success! Return null
    );
  }

  Future<String?> signup(AuthEntity entity) async {
    isLoading = true;
    notifyListeners();

    final result = await repository.register(entity);

    isLoading = false;
    notifyListeners();

    return result.fold(
      (failure) => failure.message,
      (_) => null,
    );
  }
}