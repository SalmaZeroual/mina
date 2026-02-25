import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/repositories/group_repository.dart';
import '../datasources/group_remote_datasource.dart';

class GroupRepositoryImpl implements GroupRepository {
  final GroupRemoteDataSource _remote;
  const GroupRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<GroupEntity>>> discoverGroups({int page = 1}) async {
    try {
      return Right(await _remote.discoverGroups(page: page));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<GroupEntity>>> getMyGroups() async {
    try {
      return Right(await _remote.getMyGroups());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> getGroupById(String groupId) async {
    try {
      return Right(await _remote.getGroupById(groupId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    String? description,
    bool isPremium = false,
    int priceDa = 0,
  }) async {
    try {
      return Right(await _remote.createGroup(
        name: name,
        description: description,
        isPremium: isPremium,
        priceDa: priceDa,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> join(String groupId) async {
    try {
      return Right(await _remote.join(groupId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> leave(String groupId) async {
    try {
      return Right(await _remote.leave(groupId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}