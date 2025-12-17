import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/effects.dart';
import '../../../shared/widgets/webview_screen.dart';
import '../../onboarding/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late VideoPlayerController _videoController;
  bool _isLegalPageOpen = false;
  bool _readyToNavigate = false;
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize video player
    _videoController = VideoPlayerController.asset('assets/video/loading.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          _videoController.setLooping(true);
          _videoController.play();
        }
      });

    // Check onboarding status
    _checkOnboardingStatus();

    // Navigate after delay (only if legal page is not open)
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        if (!_isLegalPageOpen) {
          _navigateNext();
        } else {
          _readyToNavigate = true;
        }
      }
    });
  }

  Future<void> _checkOnboardingStatus() async {
    final completed = await OnboardingScreen.hasCompletedOnboarding();
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = completed;
      });
    }
  }

  void _navigateNext() {
    if (_hasCompletedOnboarding == true) {
      context.go('/');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _openPrivacy() async {
    _isLegalPageOpen = true;
    await WebViewScreen.open(
      context,
      url: 'https://luxuryloungecasinoapp.com/privacy-policy/',
      title: 'Privacy Policy',
    );
    _isLegalPageOpen = false;
    if (mounted && _readyToNavigate) {
      _navigateNext();
    }
  }

  void _openTerms() async {
    _isLegalPageOpen = true;
    await WebViewScreen.open(
      context,
      url: 'https://luxuryloungecasinoapp.com/terms-and-conditions/',
      title: 'Terms of Service',
    );
    _isLegalPageOpen = false;
    if (mounted && _readyToNavigate) {
      _navigateNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/splash.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Video player - centered
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: _videoController.value.isInitialized
                  ? ClipOval(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController.value.size.width,
                            height: _videoController.value.size.height,
                            child: VideoPlayer(_videoController),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(
                      width: 150,
                      height: 150,
                    ),
              ),
            ),

            // Text image - centered below video
            Align(
              alignment: Alignment.center,
              child: Transform.translate(
                offset: const Offset(0, 40),
                child: Image.asset(
                  'assets/images/text.png',
                  width: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Privacy & Terms links at bottom
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: SafeArea(
                child: _buildLegalLinks(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _openPrivacy,
          child: Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textTertiary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('•', style: TextStyle(color: AppColors.textTertiary)),
        ),
        GestureDetector(
          onTap: _openTerms,
          child: Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.textTertiary,
            ),
          ),
        ),
      ],
    );
  }
}
