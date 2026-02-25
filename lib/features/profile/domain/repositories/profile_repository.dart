import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile(String userId);
  Future<Either<Failure, ProfileEntity>> updateProfile({String? name, String? bio});
  Future<Either<Failure, ProfileEntity>> updateAvatar(String filePath);
  Future<Either<Failure, void>> follow(String userId);
  Future<Either<Failure, void>> unfollow(String userId);
}