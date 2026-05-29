import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/models/app_user_model.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/coin_detail/presentation/screens/coin_detail_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import 'scaffold_with_nav_bar.dart';

class _AuthRouterNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouterNotifier();
  ref.onDispose(notifier.dispose);

  ref.listen<AsyncValue<AppUserModel?>>(
    authStateProvider,
    (_, __) => notifier.notify(),
  );

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,

    redirect: (context, state) {
      final authAsync = ref.read(authStateProvider);

      if (authAsync.isLoading) return null;

      final isLoggedIn = authAsync.valueOrNull != null;
      final loc = state.matchedLocation;
      final isOnAuthPage = loc == '/login' ||
          loc == '/register' ||
          loc == '/forgot-password';

      if (!isLoggedIn && !isOnAuthPage) return '/login';
      if (isLoggedIn && isOnAuthPage) return '/home';
      return null;
    },

    routes: [

      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: '/home/coin/:coinId',
        builder: (context, state) => CoinDetailScreen(
          coinId: state.pathParameters['coinId']!,
          initialImageUrl: state.extra as String?,
        ),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/portfolio',
              builder: (_, __) => const PortfolioScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (_, __) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
