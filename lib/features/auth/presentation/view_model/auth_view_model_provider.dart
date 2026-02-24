import 'package:chiya_sathi/features/auth/presentation/providers/auth_usecase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_view_model.dart';
import '../state/auth_state.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(
    ref.watch(loginUseCaseProvider),
    ref.watch(registerUseCaseProvider),
  ),
);
