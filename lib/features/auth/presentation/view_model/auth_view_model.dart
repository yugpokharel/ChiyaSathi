import 'dart:io';
import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;

  AuthViewModel(this._loginUsecase, this._registerUsecase)
      : super(const AuthState.unauthenticated());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (authEntity) => state = AuthState.authenticated(authEntity),
    );
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    File? profilePicture,
  }) async {
    state = const AuthState.loading();

    final result = await _registerUsecase(
      RegisterUsecaseParams(
        fullName: fullName,
        username: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        profilePicture: profilePicture,
      ),
    );

    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (isRegistered) {
        if (!isRegistered) {
          state = const AuthState.error("Registration failed");
          return;
        }

        state = const AuthState.unauthenticated();
      },
    );
  }
}
