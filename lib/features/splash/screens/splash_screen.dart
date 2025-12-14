import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    super.dispose();
  }

  void _openPrivacy() async {
    _isLegalPageOpen = true;
    await WebViewScreen.open(
      context,
      url: 'https://example.com',
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
      url: 'https://example.com',
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
      backgroundColor: Colors.black,
      body: ParticleBackground(
        child: Stack(
          children: [
            // Central glow - silver
            Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 300 * _pulseAnimation.value,
                    height: 300 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFD0D0D0).withOpacity(0.15),
                          const Color(0xFFD0D0D0).withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Fade to black overlay at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black,
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),

                  // App name - silver metallic gradient
                  ShaderMask(
                    shaderCallback: (bounds) {
                      return const LinearGradient(
                        colors: [
                          Color(0xFF909090),
                          Color(0xFFB8B8B8),
                          Color(0xFFE0E0E0),
                          Color(0xFFFFFFFF),
                          Color(0xFFF5F5F5),
                          Color(0xFFD8D8D8),
                          Color(0xFFB0B0B0),
                          Color(0xFF888888),
                        ],
                        stops: [0.0, 0.12, 0.3, 0.45, 0.55, 0.7, 0.88, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: const Text(
                      'LUXURY CASINO',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  Text(
                    'Premium Social Gaming',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 3,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Simple loading indicator - silver
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFD0D0D0),
                      ),
                    ),
                  ),

                  const Spacer(flex: 4),

                  // Privacy & Terms links
                  _buildLegalLinks(),

                  const SizedBox(height: 24),
                ],
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
