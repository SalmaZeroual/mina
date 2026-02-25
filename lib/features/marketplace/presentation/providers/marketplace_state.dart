import 'package:flutter/foundation.dart';
import '../../domain/entities/service_entity.dart';

@immutable
abstract class MarketplaceState {
  const MarketplaceState();
}

class MarketplaceInitial extends MarketplaceState {
  const MarketplaceInitial();
}

class MarketplaceLoading extends MarketplaceState {
  const MarketplaceLoading();
}

class MarketplaceLoaded extends MarketplaceState {
  final List<ServiceEntity> cellServices;   // services de MA cellule
  final List<ServiceEntity> allServices;    // services des autres cellules
  final List<ServiceEntity> myServices;     // mes propres services
  final String scope;                       // 'cell' | 'all'

  const MarketplaceLoaded({
    required this.cellServices,
    required this.allServices,
    required this.myServices,
    this.scope = 'cell',
  });

  MarketplaceLoaded copyWith({
    List<ServiceEntity>? cellServices,
    List<ServiceEntity>? allServices,
    List<ServiceEntity>? myServices,
    String? scope,
  }) =>
      MarketplaceLoaded(
        cellServices: cellServices ?? this.cellServices,
        allServices:  allServices  ?? this.allServices,
        myServices:   myServices   ?? this.myServices,
        scope:        scope        ?? this.scope,
      );
}

class MarketplaceError extends MarketplaceState {
  final String message;
  const MarketplaceError(this.message);
}