import 'package:flutter/foundation.dart';
import '../../domain/entities/group_entity.dart';

@immutable
abstract class GroupsState {
  const GroupsState();
}

class GroupsInitial extends GroupsState {
  const GroupsInitial();
}

class GroupsLoading extends GroupsState {
  const GroupsLoading();
}

class GroupsLoaded extends GroupsState {
  final List<GroupEntity> myGroups;
  final List<GroupEntity> discover;
  const GroupsLoaded({required this.myGroups, required this.discover});
}

class GroupsError extends GroupsState {
  final String message;
  const GroupsError(this.message);
}

// ─── Detail ──────────────────────────────────────────────────────────────────

@immutable
abstract class GroupDetailState {
  const GroupDetailState();
}

class GroupDetailInitial extends GroupDetailState {
  const GroupDetailInitial();
}

class GroupDetailLoading extends GroupDetailState {
  const GroupDetailLoading();
}

class GroupDetailLoaded extends GroupDetailState {
  final GroupEntity group;
  const GroupDetailLoaded(this.group);
}

class GroupDetailError extends GroupDetailState {
  final String message;
  const GroupDetailError(this.message);
}