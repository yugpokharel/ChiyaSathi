import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(
  () => AuthViewModel(),
);

class AuthViewModel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(RegisterUsecaseProvider);
    _loginUsecase = ref.read(LoginUsecaseProvider);
    return AuthState(); // removed const
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    String? profileImage,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _registerUsecase(
      RegisterUsecaseParams(
        fullName: fullName,
        userName: username,
        email: email,
        phoneNumber: phoneNumber,
        password: password,
        profileImage: profileImage,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        state = state.copyWith(
          status: isRegistered ? AuthStatus.registered : AuthStatus.error,
          errorMessage: isRegistered ? null : "Registration failed",
        );
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _loginUsecase(LoginUsecaseParams(
      email: email,
      password: password,
    ));

    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}
