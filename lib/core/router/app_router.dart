import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/providers/auth_state.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_email_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/groups/presentation/screens/groups_screen.dart';
import '../../features/messages/presentation/screens/messages_screen.dart';
import '../../features/marketplace/presentation/screens/marketplace_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final isAuth    = auth is AuthAuthenticated;
      final isLoading = auth is AuthInitial || auth is AuthLoading;
      final isOnAuth  = ['/welcome', '/login', '/register', '/verify-email']
          .contains(state.matchedLocation);

      if (isLoading)          return null;
      if (isAuth && isOnAuth) return '/home';
      if (!isAuth && !isOnAuth) return '/welcome';

      return null;
    },
    routes: [
      GoRoute(path: '/welcome',      builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/login',        builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',     builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) => VerifyEmailScreen(
          email: state.extra as String,
        ),
      ),
      ShellRoute(
        builder: (_, __, child) => AppBottomNav(child: child),
        routes: [
          GoRoute(path: '/home',        builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/messages',    builder: (_, __) => const MessagesScreen()),
          GoRoute(path: '/groups',      builder: (_, __) => const GroupsScreen()),
          GoRoute(path: '/marketplace', builder: (_, __) => const MarketplaceScreen()),
          GoRoute(path: '/profile',     builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],
  );
});