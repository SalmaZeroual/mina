import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/group_entity.dart';

abstract class GroupRepository {
  Future<Either<Failure, List<GroupEntity>>> discoverGroups({int page = 1});
  Future<Either<Failure, List<GroupEntity>>> getMyGroups();
  Future<Either<Failure, GroupEntity>> getGroupById(String groupId);
  Future<Either<Failure, GroupEntity>> createGroup({
    required String name,
    String? description,
    bool isPremium = false,
    int priceDa = 0,
  });
  Future<Either<Failure, void>> join(String groupId);
  Future<Either<Failure, void>> leave(String groupId);
}