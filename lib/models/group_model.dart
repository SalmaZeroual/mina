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
    );
  }
}