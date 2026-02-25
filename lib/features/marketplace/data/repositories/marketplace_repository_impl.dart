import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/service_entity.dart';
import '../../domain/repositories/marketplace_repository.dart';
import '../datasources/marketplace_remote_datasource.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remote;
  const MarketplaceRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<ServiceEntity>>> getServices({
    String scope = 'cell', int page = 1}) async {
    try {
      return Right(await _remote.getServices(scope: scope, page: page));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<ServiceEntity>>> getMyServices() async {
    try {
      return Right(await _remote.getMyServices());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> createService({
    required String title,
    required String description,
    required int priceDa,
    required String unit,
  }) async {
    try {
      return Right(await _remote.createService(
        title: title, description: description,
        priceDa: priceDa, unit: unit));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, ServiceEntity>> updateService({
    required String serviceId,
    String? title,
    String? description,
    int? priceDa,
    String? unit,
    bool? isActive,
  }) async {
    try {
      return Right(await _remote.updateService(
        serviceId: serviceId, title: title,
        description: description, priceDa: priceDa,
        unit: unit, isActive: isActive));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String serviceId) async {
    try {
      return Right(await _remote.deleteService(serviceId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}