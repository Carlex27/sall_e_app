import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../ui/screens/login/login_screen.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';
import '../ui/screens/map/map_screen.dart';
import '../ui/screens/info/info_screen.dart';
import '../ui/widgets/app_top_bar.dart';

class AppRouter {
  AppRouter();

  GoRouter get router => GoRouter(
    initialLocation: '/app/dashboard',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final atLogin  = state.matchedLocation == '/';
      if (!loggedIn) return atLogin ? null : '/';
      if (atLogin)   return '/app/dashboard';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final i = navigationShell.currentIndex;
          final titles = ['Dashboard', 'Mapa', 'Información'];
          return Scaffold(
            appBar: AppTopBar(title: titles[i]),
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              selectedIndex: i,
              onDestinationSelected: (idx) => navigationShell.goBranch(idx),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
                NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Info'),
              ],
            ),
          );
        },
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/dashboard', name: 'dashboard', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/mapa', name: 'mapa', builder: (_, __) => const MapScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/app/info', name: 'info', builder: (_, __) => const InfoScreen()),
          ]),
        ],
      ),
    ],
  );
}

/// util para refrescar go_router con un Stream (estado de auth)
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
