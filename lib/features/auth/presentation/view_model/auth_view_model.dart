import 'dart:io';
import 'package:chiya_sathi/features/auth/domain/repositories/auth_repository.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/login_usecase.dart';
import 'package:chiya_sathi/features/auth/domain/usecases/register_usecase.dart';
import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthViewModel extends StateNotifier<AuthState> {
  final LoginUsecase _loginUsecase;
  final RegisterUsecase _registerUsecase;
  final IAuthRepository _authRepository;

  AuthViewModel(this._loginUsecase, this._registerUsecase, this._authRepository)
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
    String? role,
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
        role: role,
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

  Future<bool> updateProfilePicture(File image) async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    final result = await _authRepository.updateProfilePicture(image);

    return result.fold(
      (failure) => false,
      (newUrl) {
        state = AuthState.authenticated(
          currentUser.copyWith(profilePicture: newUrl),
        );
        return true;
      },
    );
  }
}
