import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  final bool isLoading;
  final String? error;
  final AuthEntity? user;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
  });

  const AuthState.unauthenticated()
      : this(isLoading: false, user: null, error: null);

  const AuthState.loading() : this(isLoading: true, user: null, error: null);

  const AuthState.authenticated(AuthEntity user)
      : this(isLoading: false, user: user, error: null);

  const AuthState.error(String error)
      : this(isLoading: false, user: null, error: error);

  @override
  List<Object?> get props => [isLoading, error, user];
}
