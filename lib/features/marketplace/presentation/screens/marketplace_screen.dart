import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/loading_skeleton.dart';
import '../providers/marketplace_provider.dart';
import '../providers/marketplace_state.dart';
import '../widgets/service_card.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});
  @override ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    ref.read(marketplaceProvider.notifier).load();
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.greyMuted,
          labelStyle: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 11),
          tabs: const [
            Tab(text: 'MA CELLULE'),
            Tab(text: 'INTER-CELLULES'),
            Tab(text: 'MES SERVICES'),
          ],
        ),
      ),
      body: switch (state) {
        MarketplaceLoading() => const LoadingSkeleton(),
        MarketplaceError(:final message) => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.wifi_off, color: AppColors.greyMuted, size: 40),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: AppColors.greyMuted)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(marketplaceProvider.notifier).load(),
              child: const Text('Réessayer'),
            ),
          ]),
        ),
        MarketplaceLoaded(:final cellServices, :final allServices, :final myServices) =>
          TabBarView(
            controller: _tabs,
            children: [
              _ServicesList(services: cellServices),
              _ServicesList(services: allServices),
              _MyServicesList(services: myServices),
            ],
          ),
        _ => const SizedBox(),
      },
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push('/marketplace/add'),
        icon: const Icon(Icons.add, color: AppColors.white),
        label: Text('Ajouter', style: GoogleFonts.syne(
          color: AppColors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  final List services;
  const _ServicesList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(
        child: Text('Aucun service disponible.',
          style: TextStyle(color: AppColors.greyMuted)));
    }
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      onRefresh: () async {},
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (_, i) => ServiceCard(service: services[i]),
      ),
    );
  }
}

class _MyServicesList extends StatelessWidget {
  final List services;
  const _MyServicesList({required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('💼', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 16),
            Text('Propose tes services',
              style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.white)),
            const SizedBox(height: 8),
            const Text('Vends ton expertise à ta cellule ou à toutes les autres.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.greyMuted, height: 1.6)),
          ]),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: services.length,
      itemBuilder: (_, i) => ServiceCard(service: services[i], isMine: true),
    );
  }
}