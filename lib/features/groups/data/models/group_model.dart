import '../../../../core/constants/cells_config.dart';
import '../../domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.description,
    required super.cell,
    required super.creatorName,
    super.membersCount,
    super.isPremium,
    super.priceDa,
    super.isMember,
    super.myRole,
    required super.createdAt,
  });

  factory GroupModel.fromJson(Map<String, dynamic> j) => GroupModel(
    id:           j['id'] as String,
    name:         j['name'] as String,
    description:  j['description'] as String?,
    cell:         MinaCell.fromString(j['cell_id'] as String),
    creatorName:  j['creator_name'] as String? ?? '',
    membersCount: (j['members_count'] as num?)?.toInt() ?? 0,
    isPremium:    (j['is_premium'] == 1 || j['is_premium'] == true),
    priceDa:      (j['price_da'] as num?)?.toInt() ?? 0,
    isMember:     (j['is_member'] == 1 || j['is_member'] == true),
    myRole:       j['role'] as String?,
    createdAt:    DateTime.parse(j['created_at'] as String),
  );
}