import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/group_remote_datasource.dart';
import '../../data/repositories/group_repository_impl.dart';
import '../../domain/repositories/group_repository.dart';
import 'groups_state.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepositoryImpl(GroupRemoteDataSource(ref.read(apiClientProvider)));
});

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, GroupsState>((ref) {
  return GroupsNotifier(ref.read(groupRepositoryProvider));
});

final groupDetailProvider =
    StateNotifierProvider.family<GroupDetailNotifier, GroupDetailState, String>(
  (ref, groupId) =>
      GroupDetailNotifier(ref.read(groupRepositoryProvider), groupId),
);

// ─── Groups List ──────────────────────────────────────────────────────────────

class GroupsNotifier extends StateNotifier<GroupsState> {
  final GroupRepository _repo;
  GroupsNotifier(this._repo) : super(const GroupsInitial());

  // appelé par GroupsScreen initState + onRefresh
  Future<void> load() async {
    state = const GroupsLoading();
    final myResult  = await _repo.getMyGroups();
    final disResult = await _repo.discoverGroups();
    myResult.fold(
      (f) => state = GroupsError(f.message),
      (myGroups) => disResult.fold(
        (f) => state = GroupsError(f.message),
        (discover) => state = GroupsLoaded(
          myGroups: myGroups,
          discover: discover,
        ),
      ),
    );
  }

  // appelé par _DiscoverCard et _JoinButton
  Future<void> join(String groupId) async {
    final result = await _repo.join(groupId);
    result.fold(
      (f) => state = GroupsError(f.message),
      (_) => load(),
    );
  }

  // appelé par _JoinButton (quitter)
  Future<void> leave(String groupId) async {
    final result = await _repo.leave(groupId);
    result.fold(
      (f) => state = GroupsError(f.message),
      (_) => load(),
    );
  }

  // appelé par CreateGroupSheet
  Future<void> createGroup({
    required String name,
    String? description,
    bool isPremium = false,
    int priceDa = 0,
  }) async {
    final result = await _repo.createGroup(
      name: name,
      description: description,
      isPremium: isPremium,
      priceDa: priceDa,
    );
    result.fold(
      (f) => state = GroupsError(f.message),
      (_) => load(),
    );
  }
}

// ─── Group Detail ─────────────────────────────────────────────────────────────

class GroupDetailNotifier extends StateNotifier<GroupDetailState> {
  final GroupRepository _repo;
  final String groupId;
  GroupDetailNotifier(this._repo, this.groupId)
      : super(const GroupDetailInitial()) {
    load();
  }

  Future<void> load() async {
    state = const GroupDetailLoading();
    final result = await _repo.getGroupById(groupId);
    result.fold(
      (f) => state = GroupDetailError(f.message),
      (g) => state = GroupDetailLoaded(g),
    );
  }
}