import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/bottom_nav_bar.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/home/post_card.dart';
import '../../config/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mina', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 22)),
            Text(auth.currentUser?.cell ?? 'Web Development Cell', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (_, home, __) {
          if (home.isLoading) return const LoadingWidget();
          return RefreshIndicator(
            color: AppTheme.primary,
            onRefresh: home.loadPosts,
            child: ListView.separated(
              itemCount: home.posts.length,
              separatorBuilder: (_, __) => Container(height: 8, color: AppTheme.surface),
              itemBuilder: (_, i) => PostCard(
                post: home.posts[i],
                onLike: () => home.toggleLike(home.posts[i].id),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createPost),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
