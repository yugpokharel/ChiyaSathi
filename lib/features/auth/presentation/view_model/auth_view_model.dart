import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/auth_state.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_usecase_providers.dart';
import 'dart:io';

class AuthViewModel extends Notifier<AuthState> {
  late final LoginUsecase _loginUsecase;
  late final RegisterUsecase _registerUsecase;

  @override
  AuthState build() {
    _loginUsecase = ref.read(loginUsecaseProvider);
    _registerUsecase = ref.read(registerUsecaseProvider);
    return const AuthState();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(
      LoginUsecaseParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (authEntity) => state = state.copyWith(
        status: AuthStatus.authenticated,
        authEntity: authEntity,
      ),
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
    state = state.copyWith(status: AuthStatus.loading);

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
      (failure) => state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      ),
      (isRegistered) {
        if (!isRegistered) {
          state = state.copyWith(status: AuthStatus.error);
          return;
        }

        state = state.copyWith(
          status: AuthStatus.registered,
          authEntity: null,
        );
      },
    );
  }
}
