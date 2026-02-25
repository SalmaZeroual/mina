import '../../../../core/constants/cells_config.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.sellerId,
    required super.sellerName,
    super.sellerAvatar,
    required super.sellerCell,
    required super.title,
    required super.description,
    required super.priceDa,
    required super.unit,
    super.isActive,
    required super.createdAt,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
    id:           j['id'] as String,
    sellerId:     j['seller_id'] as String,
    sellerName:   j['seller_name'] as String,
    sellerAvatar: j['seller_avatar'] as String?,
    sellerCell:   MinaCell.fromString(j['seller_cell'] as String? ?? 'entrepreneur'),
    title:        j['title'] as String,
    description:  j['description'] as String,
    priceDa:      (j['price_da'] as num).toInt(),
    unit:         j['unit'] as String,
    isActive:     (j['is_active'] == 1 || j['is_active'] == true),
    createdAt:    DateTime.parse(j['created_at'] as String),
  );
}