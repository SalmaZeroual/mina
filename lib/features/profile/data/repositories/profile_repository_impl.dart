import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remote;
  const ProfileRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, ProfileEntity>> getProfile(String userId) async {
    try {
      return Right(await _remote.getProfile(userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    String? name, String? bio}) async {
    try {
      return Right(await _remote.updateProfile(name: name, bio: bio));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  @override
  Future<Either<Failure, ProfileEntity>> updateAvatar(String filePath) async {
    try {
      return Right(await _remote.updateAvatar(filePath));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> follow(String userId) async {
    try {
      return Right(await _remote.follow(userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> unfollow(String userId) async {
    try {
      return Right(await _remote.unfollow(userId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}