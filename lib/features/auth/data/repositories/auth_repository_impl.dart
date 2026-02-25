import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/constants/cells_config.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorage _storage;
  const AuthRepositoryImpl(this._remote, this._storage);

  @override
  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
    required MinaCell cell,
  }) async {
    try {
      await _remote.register(
        name: name, email: email, password: password, cell: cell);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final data  = await _remote.verifyEmail(email: email, code: code);
      final token = data['token'] as String;
      await _storage.saveToken(token);
      return Right(UserModel.fromJson(data['user'] as Map<String, dynamic>));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resendCode({required String email}) async {
    try {
      await _remote.resendCode(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data  = await _remote.login(email: email, password: password);
      final token = data['token'] as String;
      await _storage.saveToken(token);
      return Right(UserModel.fromJson(data['user'] as Map<String, dynamic>));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      return Right(await _remote.getCurrentUser());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _storage.deleteToken();
      await _storage.deleteUser();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<bool> hasToken() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }
}