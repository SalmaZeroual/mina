import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_datasource.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remote;
  const FeedRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<PostEntity>>> getCellFeed({
    required String cellId,
    int page = 1,
  }) async {
    try {
      return Right(await _remote.getCellFeed(cellId: cellId, page: page));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost({
    required String cellId,
    required String content,
    String? imageUrl,
  }) async {
    try {
      return Right(await _remote.createPost(
        cellId: cellId,
        content: content,
        imageUrl: imageUrl,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, PostEntity>> toggleLike({
    required String postId,
  }) async {
    try {
      return Right(await _remote.toggleLike(postId: postId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost({required String postId}) async {
    try {
      return Right(await _remote.deletePost(postId: postId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}