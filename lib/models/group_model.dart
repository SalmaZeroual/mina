class GroupModel {
  final String id;
  final String name;
  final String description;
  final int membersCount;
  final bool isFree;
  final double? price;
  final bool requiresApproval;
  final bool isMember;
  final bool isPending;
  final bool isAdmin;
  final String? cell;
  final String creatorId;
  final List<GroupMemberModel> previewMembers;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    required this.isFree,
    this.price,
    this.requiresApproval = false,
    this.isMember = false,
    this.isPending = false,
    this.isAdmin = false,
    this.cell,
    this.creatorId = '',
    this.previewMembers = const [],
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      membersCount: json['members_count'] ?? 0,
      isFree: json['is_free'] ?? true,
      price: json['price']?.toDouble(),
      requiresApproval: json['requires_approval'] ?? false,
      isMember: json['is_member'] ?? false,
      isPending: json['is_pending'] ?? false,
      isAdmin: json['is_admin'] ?? false,
      cell: json['cell'],
      creatorId: json['creator_id'] ?? '',
      previewMembers: (json['preview_members'] as List? ?? [])
          .map((m) => GroupMemberModel.fromJson(m))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class GroupMemberModel {
  final String id;
  final String fullName;
  final String initials;
  final String? avatarUrl;
  final String title;
  final String role;
  final bool isOnline;

  GroupMemberModel({
    required this.id,
    required this.fullName,
    required this.initials,
    this.avatarUrl,
    this.title = '',
    this.role = 'member',
    this.isOnline = false,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final name = json['full_name'] ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return GroupMemberModel(
      id: json['id'] ?? '',
      fullName: name,
      initials: json['initials'] ?? initials,
      avatarUrl: json['avatar_url'],
      title: json['title'] ?? '',
      role: json['role'] ?? 'member',
      isOnline: json['is_online'] ?? false,
    );
  }
}

class JoinRequestModel {
  final String id;
  final Map<String, dynamic> user;
  final DateTime createdAt;

  JoinRequestModel({required this.id, required this.user, required this.createdAt});

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    final name = json['full_name'] ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return JoinRequestModel(
      id: json['id'],
      user: {
        'id': json['user_id'] ?? '',
        'full_name': name,
        'initials': initials,
        'title': json['title'] ?? '',
        'avatar_url': json['avatar_url'],
      },
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}