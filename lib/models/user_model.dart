class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;
  final String initials;
  final String cellId;
  final String cell;
  final String title;
  final String? location;
  final String? company;
  final String? about;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final int connectionsCount;
  final int mutualConnections;
  final String networkVisibility; // 'public' | 'connections_only' | 'private'
  final DateTime joinedAt;
  final bool isOnline;
  // Social state
  final bool isFollowing;
  final String? connectionStatus;
  final String? connectionId;
  final bool iAmRequester;
  final bool isBlocked;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
    required this.initials,
    required this.cellId,
    this.cell = '',
    this.title = '',
    this.location,
    this.company,
    this.about,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.connectionsCount = 0,
    this.mutualConnections = 0,
    this.networkVisibility = 'public',
    required this.joinedAt,
    this.isOnline = false,
    this.isFollowing = false,
    this.connectionStatus,
    this.connectionId,
    this.iAmRequester = false,
    this.isBlocked = false,
  });

  bool get isConnected        => connectionStatus == 'accepted';
  bool get isPendingConnection => connectionStatus == 'pending';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final fullName = (json['full_name'] as String?) ?? (json['name'] as String?) ?? '';
    return UserModel(
      id:                 (json['id']           as String?) ?? '',
      fullName:           fullName,
      email:              (json['email']        as String?) ?? '',
      avatarUrl:           json['avatar_url']   as String?,
      initials:           (json['initials']     as String?) ?? _getInitials(fullName),
      cellId:             (json['cell_id']      as String?) ?? '',
      cell:               (json['cell']         as String?) ?? (json['cell_name'] as String?) ?? '',
      title:              (json['title']        as String?) ?? '',
      location:            json['location']     as String?,
      company:             json['company']      as String?,
      about:               json['about']        as String?,
      postsCount:         (json['posts_count']       as int?) ?? 0,
      followersCount:     (json['followers_count']   as int?) ?? 0,
      followingCount:     (json['following_count']   as int?) ?? 0,
      connectionsCount:   (json['connections_count'] as int?) ?? 0,
      mutualConnections:  (json['mutual_connections'] as int?) ?? 0,
      networkVisibility:  (json['network_visibility'] as String?) ?? 'public',
      joinedAt:           DateTime.tryParse(
          (json['joined_at'] as String?) ?? (json['created_at'] as String?) ?? '') ?? DateTime.now(),
      isOnline:           json['is_online'] == true || json['is_online'] == 1,
      isFollowing:        json['is_following'] == true || json['is_following'] == 1,
      connectionStatus:   json['connection_status'] as String?,
      connectionId:       json['connection_id']     as String?,
      iAmRequester:       json['i_am_requester'] == true || json['i_am_requester'] == 1,
      isBlocked:          json['is_blocked'] == true || json['is_blocked'] == 1,
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}