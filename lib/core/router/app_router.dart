import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'scaffold_with_nav_bar.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/coin_detail/presentation/screens/coin_detail_screen.dart';
import '../../features/portfolio/presentation/screens/portfolio_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Exposes the app's [GoRouter] instance to the widget tree via Riverpod.
/// Swap the inner [Provider] for a [StateProvider] or generated @riverpod
/// provider once authentication state is wired up.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: kDebugMode,

    // TODO: replace with real auth redirect in a later session
    // redirect: (context, state) { ... },

    routes: [
      // ── Auth screens (full-screen, no nav bar) ───────────────
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ── Coin detail: pushed on top, no nav bar ───────────────
      // Use context.push('/home/coin/<id>') to navigate here so
      // the back button returns to the previous shell tab.
      GoRoute(
        path: '/home/coin/:coinId',
        builder: (context, state) => CoinDetailScreen(
          coinId: state.pathParameters['coinId']!,
        ),
      ),

      // ── Main shell: three tabs with preserved state ──────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: [
          // Branch 0 — Home / Market
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1 — Portfolio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/portfolio',
                builder: (context, state) => const PortfolioScreen(),
              ),
            ],
          ),

          // Branch 2 — Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
