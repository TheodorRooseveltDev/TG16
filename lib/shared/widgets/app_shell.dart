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

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  bool _musicInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Start music after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initMusic();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final audioService = ref.read(audioServiceProvider);
    final musicEnabled = ref.read(musicEnabledProvider);

    if (state == AppLifecycleState.paused) {
      // Pause music when app goes to background
      audioService.pauseBackgroundMusic();
    } else if (state == AppLifecycleState.resumed) {
      // Resume music when app comes back
      audioService.resumeBackgroundMusic(enabled: musicEnabled);
    }
  }

  Future<void> _initMusic() async {
    if (_musicInitialized) return;
    _musicInitialized = true;

    final audioService = ref.read(audioServiceProvider);
    final musicEnabled = ref.read(musicEnabledProvider);

    if (musicEnabled) {
      await audioService.playBackgroundMusic(enabled: true);
    }
  }

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
