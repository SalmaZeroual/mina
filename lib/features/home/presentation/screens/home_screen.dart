import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/loading_skeleton.dart';
import '../providers/feed_provider.dart';
import '../providers/feed_state.dart';
import '../widgets/cell_banner.dart';
import '../widgets/new_post_bar.dart';
import '../widgets/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    ref.read(feedProvider.notifier).load();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 400) {
        final s = ref.read(feedProvider);
        if (s is FeedLoaded && s.hasMore) ref.read(feedProvider.notifier).load();
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedProvider);

    return Scaffold(
      appBar: AppBar(
        title: RichText(text: TextSpan(children: [
          TextSpan(text: 'M', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
          TextSpan(text: 'ina', style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.white)),
        ])),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          Stack(children: [
            IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
            Positioned(right: 8, top: 8,
              child: Container(width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle))),
          ]),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () => ref.read(feedProvider.notifier).load(refresh: true),
        child: CustomScrollView(
          controller: _scroll,
          slivers: [
            const SliverToBoxAdapter(child: CellBanner()),
            const SliverToBoxAdapter(child: NewPostBar()),
            switch (state) {
              FeedLoading() => const SliverToBoxAdapter(child: LoadingSkeleton()),
              FeedLoaded(:final posts) => posts.isEmpty
                ? SliverToBoxAdapter(child: _empty())
                : SliverList.builder(
                    itemCount: posts.length,
                    itemBuilder: (_, i) => PostCard(post: posts[i]),
                  ),
              FeedError(:final message) => SliverToBoxAdapter(
                  child: Center(child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(children: [
                      const Icon(Icons.wifi_off, color: AppColors.greyMuted, size: 40),
                      const SizedBox(height: 12),
                      Text(message, style: const TextStyle(color: AppColors.greyMuted)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.read(feedProvider.notifier).load(refresh: true),
                        child: const Text('Réessayer'),
                      ),
                    ]),
                  )),
                ),
              _ => const SliverToBoxAdapter(child: SizedBox()),
            },
          ],
        ),
      ),
    );
  }

  Widget _empty() => const Center(
    child: Padding(
      padding: EdgeInsets.all(40),
      child: Column(children: [
        Text('🚀', style: TextStyle(fontSize: 40)),
        SizedBox(height: 12),
        Text('Sois le premier à poster dans ta cellule !',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.greyMuted)),
      ]),
    ),
  );
}