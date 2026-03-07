import 'package:chiya_sathi/features/auth/presentation/state/auth_state.dart';
import 'package:chiya_sathi/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tUser = AuthEntity(
    id: '1',
    fullName: 'Test',
    username: 'test',
    email: 'test@test.com',
    phoneNumber: '123',
    token: 'tok',
  );

  group('AuthState', () {
    test('default constructor has correct defaults', () {
      const state = AuthState();
      expect(state.isLoading, false);
      expect(state.error, isNull);
      expect(state.user, isNull);
    });

    test('unauthenticated factory creates correct state', () {
      const state = AuthState.unauthenticated();
      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('loading factory creates correct state', () {
      const state = AuthState.loading();
      expect(state.isLoading, true);
      expect(state.user, isNull);
      expect(state.error, isNull);
    });

    test('authenticated factory stores user', () {
      const state = AuthState.authenticated(tUser);
      expect(state.isLoading, false);
      expect(state.user, tUser);
      expect(state.error, isNull);
    });

    test('error factory stores error message', () {
      const state = AuthState.error('Something went wrong');
      expect(state.isLoading, false);
      expect(state.user, isNull);
      expect(state.error, 'Something went wrong');
    });

    test('supports Equatable equality', () {
      const state1 = AuthState.unauthenticated();
      const state2 = AuthState.unauthenticated();
      expect(state1, equals(state2));
    });

    test('different states are not equal', () {
      const loading = AuthState.loading();
      const unauth = AuthState.unauthenticated();
      expect(loading, isNot(equals(unauth)));
    });

    test('props contain all fields', () {
      const state = AuthState.error('err');
      expect(state.props, [false, 'err', null]);
    });
  });
}
