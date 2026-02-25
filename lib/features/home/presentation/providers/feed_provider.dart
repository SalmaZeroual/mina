import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/feed_remote_datasource.dart';
import '../../data/repositories/feed_repository_impl.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import 'feed_state.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  final client = ref.read(apiClientProvider);
  // FeedRemoteDataSource est une classe concrète (pas abstract)
  return FeedRepositoryImpl(FeedRemoteDataSource(client));
});

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  return FeedNotifier(ref.read(feedRepositoryProvider), ref);
});

class FeedNotifier extends StateNotifier<FeedState> {
  final FeedRepository _repo;
  final Ref _ref;
  int _page = 1;

  FeedNotifier(this._repo, this._ref) : super(const FeedInitial());

  // UserEntity.cell est MinaCell — on prend cell.id pour l'API
  String get _cellId {
    final auth = _ref.read(authProvider);
    if (auth is AuthAuthenticated) return auth.user.cell.id;
    return '';
  }

  // appelé par HomeScreen initState, onRefresh(refresh:true), scroll listener
  Future<void> load({bool refresh = false}) async {
    if (refresh) _page = 1;
    if (state is FeedLoading) return;
    if (refresh || state is FeedInitial) state = const FeedLoading();

    final result = await _repo.getCellFeed(cellId: _cellId, page: _page);
    result.fold(
      (failure) => state = FeedError(failure.message),
      (newPosts) {
        final existing = (state is FeedLoaded)
            ? (state as FeedLoaded).posts
            : <dynamic>[];
        final allPosts = refresh ? newPosts : [...existing, ...newPosts];
        final hasMore  = newPosts.isNotEmpty;
        if (hasMore) _page++;
        state = FeedLoaded(posts: List.from(allPosts), hasMore: hasMore);
      },
    );
  }

  // appelé par NewPostBar : createPost(ctrl.text.trim())
  Future<void> createPost(String content, {String? imageUrl}) async {
    final result = await _repo.createPost(
      cellId: _cellId,
      content: content,
      imageUrl: imageUrl,
    );
    result.fold(
      (failure) => state = FeedError(failure.message),
      (_) => load(refresh: true),
    );
  }

  // appelé par PostCard : toggleLike(post.id)
  // Optimistic update avec PostEntity.copyWith(isLikedByMe, likesCount)
  Future<void> toggleLike(String postId) async {
    // Optimistic UI update
    if (state is FeedLoaded) {
      final posts = (state as FeedLoaded).posts.map((p) {
        if (p.id != postId) return p;
        return p.copyWith(
          isLikedByMe: !p.isLikedByMe,
          likesCount: p.isLikedByMe ? p.likesCount - 1 : p.likesCount + 1,
        );
      }).toList();
      state = FeedLoaded(posts: posts, hasMore: (state as FeedLoaded).hasMore);
    }

    // Appel API
    final result = await _repo.toggleLike(postId: postId);
    result.fold(
      // En cas d'erreur, on recharge pour avoir l'état correct
      (failure) => load(refresh: true),
      (updated) {
        if (state is FeedLoaded) {
          final posts = (state as FeedLoaded).posts.map((p) {
            return p.id == postId ? updated : p;
          }).toList();
          state = FeedLoaded(
            posts: posts,
            hasMore: (state as FeedLoaded).hasMore,
          );
        }
      },
    );
  }

  // appelé si owner supprime son post
  Future<void> deletePost(String postId) async {
    final result = await _repo.deletePost(postId: postId);
    result.fold(
      (failure) => state = FeedError(failure.message),
      (_) => load(refresh: true),
    );
  }
}