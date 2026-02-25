import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/post_entity.dart';

abstract class FeedRepository {
  Future<Either<Failure, List<PostEntity>>> getCellFeed({
    required String cellId,
    int page = 1,
  });

  Future<Either<Failure, PostEntity>> createPost({
    required String cellId,
    required String content,
    String? imageUrl,
  });

  Future<Either<Failure, PostEntity>> toggleLike({required String postId});

  Future<Either<Failure, void>> deletePost({required String postId});
}