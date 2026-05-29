import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';

/// Persistent shell that wraps the three main tabs with a [NavigationBar].
/// Receives [navigationShell] from [StatefulShellRoute.indexedStack], which
/// keeps each branch's navigator alive so tab state is never lost on switch.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final destinations = [
      NavigationDestination(
        icon: const Icon(Icons.trending_up_outlined),
        selectedIcon: const Icon(Icons.trending_up),
        label: l10n.home,
      ),
      NavigationDestination(
        icon: const Icon(Icons.pie_chart_outline_rounded),
        selectedIcon: const Icon(Icons.pie_chart_rounded),
        label: l10n.portfolio,
      ),
      NavigationDestination(
        icon: const Icon(Icons.person_outline_rounded),
        selectedIcon: const Icon(Icons.person_rounded),
        label: l10n.profile,
      ),
    ];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: destinations,
        animationDuration: const Duration(milliseconds: 250),
      ),
    );
  }

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
