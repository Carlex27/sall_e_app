import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/login/login_screen.dart';
import '../ui/screens/dashboard/dashboard_screen.dart';
import '../ui/screens/map/map_screen.dart';
import '../ui/screens/info/info_screen.dart';
import '../ui/widgets/app_top_bar.dart';

class AppRouter {
  AppRouter();

  GoRouter get router => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Shell con bottom nav y barra superior
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final currentIndex = navigationShell.currentIndex;
          final titles = ['Dashboard', 'Mapa', 'Información'];
          return Scaffold(
            appBar: AppTopBar(title: titles[currentIndex]),
            body: navigationShell, // aquí se renderiza el contenido de cada rama
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (i) => navigationShell.goBranch(i),
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
                NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
                NavigationDestination(icon: Icon(Icons.info_outline), selectedIcon: Icon(Icons.info), label: 'Info'),
              ],
            ),
          );
        },
        branches: [
          // Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Mapa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/mapa',
                name: 'mapa',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          // Info
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/app/info',
                name: 'info',
                builder: (context, state) => const InfoScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
