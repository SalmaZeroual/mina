import 'package:equatable/equatable.dart';
import '../../../../core/constants/cells_config.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerAvatar;
  final MinaCell sellerCell;
  final String title;
  final String description;
  final int priceDa;
  final String unit;
  final bool isActive;
  final DateTime createdAt;

  const ServiceEntity({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerAvatar,
    required this.sellerCell,
    required this.title,
    required this.description,
    required this.priceDa,
    required this.unit,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id];
}