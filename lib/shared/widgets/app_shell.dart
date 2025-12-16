import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/premium_navbar.dart';
import '../widgets/effects.dart';
import '../../core/services/audio_service.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/games')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onNavTap(int index) {
    final audioService = ref.read(audioServiceProvider);
    final soundEnabled = ref.read(soundEnabledProvider);
    final vibrationEnabled = ref.read(vibrationEnabledProvider);

    // Play tap sound and vibrate
    audioService.playTapSound(enabled: soundEnabled);
    audioService.lightVibrate(enabled: vibrationEnabled);

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
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: ParticleBackground(
        child: Stack(
          children: [
            // Main content
            widget.child,

            // Top gradient safe area overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: topPadding + 20,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Color(0xCC000000), // black with 80% opacity
                        Color(0x66000000), // black with 40% opacity
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.3, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),

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
