import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class AppBottomNav extends StatelessWidget {
  final Widget child;
  const AppBottomNav({super.key, required this.child});

  static const _tabs = ['/home', '/messages', '/groups', '/marketplace', '/profile'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabs.indexWhere((t) => location.startsWith(t));

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.black,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: idx < 0 ? 0 : idx,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.greyLight,
          type: BottomNavigationBarType.fixed,
          onTap: (i) => context.go(_tabs[i]),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),       activeIcon: Icon(Icons.home),       label: AppStrings.home),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline),  activeIcon: Icon(Icons.chat_bubble), label: AppStrings.messages),
            BottomNavigationBarItem(icon: Icon(Icons.group_outlined),       activeIcon: Icon(Icons.group),       label: AppStrings.groups),
            BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined),  activeIcon: Icon(Icons.storefront),  label: AppStrings.marketplace),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),       activeIcon: Icon(Icons.person),      label: AppStrings.profile),
          ],
        ),
      ),
    );
  }
}