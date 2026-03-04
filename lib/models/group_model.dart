class GroupModel {
  final String id;
  final String name;
  final String description;
  final int membersCount;       // -1 = hidden by creator
  final bool showMembersCount;
  final bool isFree;
  final double price;
  final bool requiresApproval;
  final bool isMember;
  final bool isPending;
  final bool isAdmin;
  final String? cell;
  final String? cellId;
  final String creatorId;
  final List<GroupMemberModel> previewMembers;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.description,
    required this.membersCount,
    this.showMembersCount = true,
    required this.isFree,
    this.price = 0,
    this.requiresApproval = false,
    this.isMember = false,
    this.isPending = false,
    this.isAdmin = false,
    this.cell,
    this.cellId,
    this.creatorId = '',
    this.previewMembers = const [],
    required this.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      id:               json['id']               as String? ?? '',
      name:             json['name']             as String? ?? '',
      description:      json['description']      as String? ?? '',
      membersCount:     json['members_count']    as int?    ?? 0,
      showMembersCount: json['show_members_count'] != false,
      isFree:           json['is_free']          == true || json['is_free'] == 1,
      price:            (json['price']           as num?    ?? 0).toDouble(),
      requiresApproval: json['requires_approval'] == true || json['requires_approval'] == 1,
      isMember:         json['is_member']        == true,
      isPending:        json['is_pending']       == true,
      isAdmin:          json['is_admin']         == true,
      cell:             json['cell']             as String?,
      cellId:           json['cell_id']          as String?,
      creatorId:        json['creator_id']       as String? ?? '',
      previewMembers:   (json['preview_members'] as List? ?? [])
          .map((m) => GroupMemberModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class GroupMemberModel {
  final String id;
  final String fullName;
  final String initials;
  final String? avatarUrl;
  final String title;
  final String role;   // 'admin' | 'member'
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
    final name = json['full_name'] as String? ?? '';
    final parts = name.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    return GroupMemberModel(
      id:        json['id']         as String? ?? '',
      fullName:  name,
      initials:  json['initials']   as String? ?? initials,
      avatarUrl: json['avatar_url'] as String?,
      title:     json['title']      as String? ?? '',
      role:      json['role']       as String? ?? 'member',
      isOnline:  json['is_online']  == true || json['is_online'] == 1,
    );
  }
}

class JoinRequestModel {
  final String id;
  final Map<String, dynamic> user;
  final DateTime createdAt;

  JoinRequestModel({required this.id, required this.user, required this.createdAt});

  factory JoinRequestModel.fromJson(Map<String, dynamic> json) {
    return JoinRequestModel(
      id:        json['id'] as String? ?? '',
      user:      json['user'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

class GroupPostModel {
  final String id;
  final String content;
  final bool isPinned;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final Map<String, dynamic> author;

  GroupPostModel({
    required this.id,
    required this.content,
    this.isPinned = false,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
    required this.author,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24)   return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  factory GroupPostModel.fromJson(Map<String, dynamic> json) => GroupPostModel(
    id:            json['id']             as String? ?? '',
    content:       json['content']        as String? ?? '',
    isPinned:      json['is_pinned']      == true || json['is_pinned'] == 1,
    likesCount:    json['likes_count']    as int?    ?? 0,
    commentsCount: json['comments_count'] as int?    ?? 0,
    isLiked:       json['is_liked']       == true,
    createdAt:     DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    author:        json['author']         as Map<String, dynamic>? ?? {},
  );

  GroupPostModel copyWith({bool? isLiked, int? likesCount, bool? isPinned}) => GroupPostModel(
    id: id, content: content, createdAt: createdAt, author: author,
    isPinned:      isPinned      ?? this.isPinned,
    likesCount:    likesCount    ?? this.likesCount,
    commentsCount: commentsCount,
    isLiked:       isLiked       ?? this.isLiked,
  );
}

class GroupCommentModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final Map<String, dynamic> author;

  GroupCommentModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.author,
  });

  factory GroupCommentModel.fromJson(Map<String, dynamic> json) => GroupCommentModel(
    id:        json['id']         as String? ?? '',
    content:   json['content']    as String? ?? '',
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    author:    json['author']     as Map<String, dynamic>? ?? {},
  );
}