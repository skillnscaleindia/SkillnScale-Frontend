import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import 'user_provider.dart';


enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(AuthState());

  Future<void> signIn(String identifier, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final userRole = await _ref.read(authServiceProvider).signIn(identifier, password);
      _ref.read(userRoleProvider.notifier).state = userRole;
      state = state.copyWith(status: AuthStatus.authenticated, errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: 'Sign-in failed. Check credentials.');
    }
  }
}
