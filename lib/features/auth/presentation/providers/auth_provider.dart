import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/constants/cells_config.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client  = ref.read(apiClientProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepositoryImpl(AuthRemoteDataSource(client), storage);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthInitial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = const AuthLoading();
    final hasToken = await _repo.hasToken();
    if (!hasToken) {
      state = const AuthUnauthenticated();
      return;
    }
    try {
      final result = await _repo.getCurrentUser().timeout(
        const Duration(seconds: 5),
        onTimeout: () => const Left(AuthFailure('Timeout')),
      );
      result.fold(
        (_) => state = const AuthUnauthenticated(),
        (user) => state = AuthAuthenticated(user),
      );
    } catch (_) {
      state = const AuthUnauthenticated();
    }
  }

  Future<void> checkSession() => checkAuth();

  // appelé par LoginScreen
  Future<void> signIn(String email, String password) async {
    state = const AuthLoading();
    final result = await _repo.login(email: email, password: password);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // appelé par RegisterScreen — retourne AuthRegistered si ok
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required MinaCell cell,
  }) async {
    state = const AuthLoading();
    final result = await _repo.register(
      name: name, email: email, password: password, cell: cell);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = AuthRegistered(email), // email pour la page verify
    );
  }

  // appelé par VerifyEmailScreen
  Future<void> verifyEmail({required String email, required String code}) async {
    state = const AuthLoading();
    final result = await _repo.verifyEmail(email: email, code: code);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  // appelé par VerifyEmailScreen (renvoyer)
  Future<void> resendCode({required String email}) async {
    final result = await _repo.resendCode(email: email);
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) {},
    );
  }

  // appelé par ProfileScreen
  Future<void> signOut() async {
    state = const AuthLoading();
    final result = await _repo.logout();
    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }

  Future<void> logout() => signOut();
}