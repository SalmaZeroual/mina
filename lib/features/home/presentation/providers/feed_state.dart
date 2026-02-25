import 'package:flutter/foundation.dart';
import '../../domain/entities/post_entity.dart';

@immutable
abstract class FeedState {
  const FeedState();
}

class FeedInitial extends FeedState {
  const FeedInitial();
}

class FeedLoading extends FeedState {
  const FeedLoading();
}

class FeedLoaded extends FeedState {
  final List<PostEntity> posts;
  final bool hasMore;
  const FeedLoaded({required this.posts, this.hasMore = false});
}

class FeedError extends FeedState {
  final String message;
  const FeedError(this.message);
}