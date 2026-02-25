import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    ProfileRemoteDataSource(ref.read(apiClientProvider)),
  );
});

// family par userId — fonctionne pour mon profil ET le profil des autres
final profileProvider =
    StateNotifierProvider.family<ProfileNotifier, ProfileState, String>(
  (ref, userId) => ProfileNotifier(
    ref.read(profileRepositoryProvider),
    userId,
  ),
);

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repo;
  final String userId;

  ProfileNotifier(this._repo, this.userId) : super(const ProfileInitial()) {
    load();
  }

  // appelé par ProfileScreen initState
  Future<void> load() async {
    state = const ProfileLoading();
    final result = await _repo.getProfile(userId);
    result.fold(
      (f) => state = ProfileError(f.message),
      (p) => state = ProfileLoaded(p),
    );
  }

  // appelé par ProfileScreen _pickAvatar
  Future<void> updateAvatar(String filePath) async {
    final result = await _repo.updateAvatar(filePath);
    result.fold(
      (f) => state = ProfileError(f.message),
      (p) => state = ProfileLoaded(p),
    );
  }

  // appelé par EditProfileSheet
  Future<void> updateProfile({String? name, String? bio}) async {
    final result = await _repo.updateProfile(name: name, bio: bio);
    result.fold(
      (f) => state = ProfileError(f.message),
      (p) => state = ProfileLoaded(p),
    );
  }

  // appelé par FollowButton — toggle automatique
  Future<void> toggleFollow() async {
    if (state is! ProfileLoaded) return;
    final profile = (state as ProfileLoaded).profile;

    // Optimistic update
    state = ProfileLoaded(profile.copyWith(
      isFollowedByMe: !profile.isFollowedByMe,
      followersCount: profile.isFollowedByMe
          ? profile.followersCount - 1
          : profile.followersCount + 1,
    ));

    final result = profile.isFollowedByMe
        ? await _repo.unfollow(userId)
        : await _repo.follow(userId);

    result.fold(
      (f) {
        // Rollback si erreur
        state = ProfileLoaded(profile);
        state = ProfileError(f.message);
      },
      (_) {},
    );
  }
}