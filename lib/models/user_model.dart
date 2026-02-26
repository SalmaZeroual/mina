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
  final DateTime joinedAt;
  final bool isOnline;

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
    required this.joinedAt,
    this.isOnline = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      initials: json['initials'] ?? _getInitials(json['full_name']),
      cellId: json['cell_id'] ?? '',
      cell: json['cell'] ?? '',
      title: json['title'] ?? '',
      location: json['location'],
      company: json['company'],
      about: json['about'],
      postsCount: json['posts_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      joinedAt: DateTime.tryParse(json['joined_at'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      isOnline: json['is_online'] ?? false,
    );
  }

  static String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }
}