import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/games/screens/games_screen.dart';
import '../../features/games/screens/game_detail_screen.dart';
import '../../features/games/models/game.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../widgets/app_shell.dart';

// Current tab index provider for navigation
final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    // Splash screen (outside shell - no navbar)
    GoRoute(
      path: '/splash',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    // Onboarding screen (outside shell - no navbar)
    GoRoute(
      path: '/onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: HomeScreen(
                onNavigateToGames: () => context.go('/games'),
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Fade in the new page, fade out when leaving
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0)
                        .animate(CurveTween(curve: Curves.easeInOut).animate(secondaryAnimation)),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/games',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const GamesScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Fade in the new page, fade out when leaving
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0)
                        .animate(CurveTween(curve: Curves.easeInOut).animate(secondaryAnimation)),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                // Fade in the new page, fade out when leaving
                return FadeTransition(
                  opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 1.0, end: 0.0)
                        .animate(CurveTween(curve: Curves.easeInOut).animate(secondaryAnimation)),
                    child: child,
                  ),
                );
              },
            );
          },
        ),
      ],
    ),
    // Game detail route (outside shell - no navbar)
    GoRoute(
      path: '/game/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final game = state.extra as Game;
        return CustomTransitionPage(
          key: state.pageKey,
          child: GameDetailScreen(game: game),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        );
      },
    ),
  ],
);
