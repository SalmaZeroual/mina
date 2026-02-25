import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/cells_config.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> register({
    required String name,
    required String email,
    required String password,
    required MinaCell cell,
  });

  Future<Either<Failure, UserEntity>> verifyEmail({
    required String email,
    required String code,
  });

  Future<Either<Failure, void>> resendCode({required String email});

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, void>> logout();

  Future<bool> hasToken();
}