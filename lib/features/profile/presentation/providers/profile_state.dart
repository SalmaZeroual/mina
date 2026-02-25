import 'package:flutter/foundation.dart';
import '../../domain/entities/profile_entity.dart';

@immutable
abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final ProfileEntity profile;
  const ProfileLoaded(this.profile);

  ProfileLoaded copyWith({ProfileEntity? profile}) =>
      ProfileLoaded(profile ?? this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);
}