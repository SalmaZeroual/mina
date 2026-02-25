import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/service_entity.dart';

abstract class MarketplaceRepository {
  Future<Either<Failure, List<ServiceEntity>>> getServices({String scope = 'cell', int page = 1});
  Future<Either<Failure, List<ServiceEntity>>> getMyServices();
  Future<Either<Failure, ServiceEntity>> createService({
    required String title,
    required String description,
    required int priceDa,
    required String unit,
  });
  Future<Either<Failure, ServiceEntity>> updateService({
    required String serviceId,
    String? title,
    String? description,
    int? priceDa,
    String? unit,
    bool? isActive,
  });
  Future<Either<Failure, void>> deleteService(String serviceId);
}