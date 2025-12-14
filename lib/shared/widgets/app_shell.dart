import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/premium_navbar.dart';
import '../widgets/effects.dart';

class AppShell extends StatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/games')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/games');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ParticleBackground(
        child: Stack(
          children: [
            // Main content
            widget.child,

            // Premium floating navbar
            PremiumNavbar(
              currentIndex: _getCurrentIndex(context),
              onTap: _onNavTap,
            ),
          ],
        ),
      ),
    );
  }
}
