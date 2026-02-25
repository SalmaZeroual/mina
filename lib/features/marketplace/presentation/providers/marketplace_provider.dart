import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/marketplace_remote_datasource.dart';
import '../../data/repositories/marketplace_repository_impl.dart';
import '../../domain/repositories/marketplace_repository.dart';
import 'marketplace_state.dart';

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  return MarketplaceRepositoryImpl(
    MarketplaceRemoteDataSource(ref.read(apiClientProvider)),
  );
});

final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, MarketplaceState>((ref) {
  return MarketplaceNotifier(ref.read(marketplaceRepositoryProvider));
});

class MarketplaceNotifier extends StateNotifier<MarketplaceState> {
  final MarketplaceRepository _repo;
  MarketplaceNotifier(this._repo) : super(const MarketplaceInitial());

  // appelé par MarketplaceScreen initState + onRefresh
  Future<void> load() async {
    state = const MarketplaceLoading();
    final cellResult = await _repo.getServices(scope: 'cell');
    final allResult  = await _repo.getServices(scope: 'all');
    final myResult   = await _repo.getMyServices();

    cellResult.fold(
      (f) => state = MarketplaceError(f.message),
      (cellServices) => allResult.fold(
        (f) => state = MarketplaceError(f.message),
        (allServices) => myResult.fold(
          (f) => state = MarketplaceError(f.message),
          (myServices) => state = MarketplaceLoaded(
            cellServices: cellServices,
            allServices:  allServices,
            myServices:   myServices,
          ),
        ),
      ),
    );
  }

  // appelé par MarketplaceScreen tab switch
  void setScope(String scope) {
    if (state is MarketplaceLoaded) {
      state = (state as MarketplaceLoaded).copyWith(scope: scope);
    }
  }

  // appelé par CreateServiceSheet
  Future<void> createService({
    required String title,
    required String description,
    required int priceDa,
    required String unit,
  }) async {
    final result = await _repo.createService(
      title: title, description: description,
      priceDa: priceDa, unit: unit,
    );
    result.fold(
      (f) => state = MarketplaceError(f.message),
      (_) => load(),
    );
  }

  // appelé par MyServiceCard (toggle actif/inactif)
  Future<void> toggleActive(String serviceId, bool isActive) async {
    final result = await _repo.updateService(
      serviceId: serviceId, isActive: isActive);
    result.fold(
      (f) => state = MarketplaceError(f.message),
      (_) => load(),
    );
  }

  // appelé par MyServiceCard (supprimer)
  Future<void> deleteService(String serviceId) async {
    final result = await _repo.deleteService(serviceId);
    result.fold(
      (f) => state = MarketplaceError(f.message),
      (_) => load(),
    );
  }
}