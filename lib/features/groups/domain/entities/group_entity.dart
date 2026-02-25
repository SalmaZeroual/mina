import 'package:equatable/equatable.dart';
import '../../../../core/constants/cells_config.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final MinaCell cell;
  final String creatorName;
  final int membersCount;
  final bool isPremium;
  final int priceDa;
  final bool isMember;
  final String? myRole;   // 'admin' | 'member' | null
  final DateTime createdAt;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    required this.cell,
    required this.creatorName,
    this.membersCount = 0,
    this.isPremium = false,
    this.priceDa = 0,
    this.isMember = false,
    this.myRole,
    required this.createdAt,
  });

  GroupEntity copyWith({bool? isMember, int? membersCount, String? myRole}) => GroupEntity(
    id: id, name: name, description: description, cell: cell,
    creatorName: creatorName, isPremium: isPremium, priceDa: priceDa,
    createdAt: createdAt,
    isMember:     isMember     ?? this.isMember,
    membersCount: membersCount ?? this.membersCount,
    myRole:       myRole       ?? this.myRole,
  );

  @override
  List<Object?> get props => [id];
}