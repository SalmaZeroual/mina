import 'package:flutter/foundation.dart';
import '../../domain/entities/user_entity.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;
  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

// Après register — en attente de vérification email
class AuthRegistered extends AuthState {
  final String email;
  const AuthRegistered(this.email);
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}