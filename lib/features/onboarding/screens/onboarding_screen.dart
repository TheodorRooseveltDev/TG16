import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/effects.dart';
import '../../../shared/widgets/webview_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const String hasCompletedOnboardingKey = 'has_completed_onboarding';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(hasCompletedOnboardingKey) ?? false;
  }

  static Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(hasCompletedOnboardingKey, true);
  }

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _isOver18 = false;
  bool _acceptTermsAndPrivacy = false;

  bool get _canContinue => _isOver18 && _acceptTermsAndPrivacy;

  void _onContinue() async {
    if (_canContinue) {
      await OnboardingScreen.setOnboardingCompleted();
      if (mounted) {
        context.go('/');
      }
    }
  }

  void _openTerms() async {
    await WebViewScreen.open(
      context,
      url: 'https://example.com',
      title: 'Terms & Conditions',
    );
  }

  void _openPrivacy() async {
    await WebViewScreen.open(
      context,
      url: 'https://example.com',
      title: 'Privacy Policy',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: ParticleBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  // App Icon with glow
                  _buildIconWithGlow(),

                  const SizedBox(height: 32),

                  // Welcome text
                  Text(
                    'Welcome!',
                    style: AppTypography.headingLarge.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'These games are intended for an adult\naudience (18+).',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Terms & Privacy links
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Please review and accept our ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _openTerms,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF909090),
                              Color(0xFFD0D0D0),
                              Color(0xFFFFFFFF),
                              Color(0xFFD0D0D0),
                              Color(0xFF909090),
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'Terms & Conditions',
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        ' and ',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openPrivacy,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF909090),
                              Color(0xFFD0D0D0),
                              Color(0xFFFFFFFF),
                              Color(0xFFD0D0D0),
                              Color(0xFF909090),
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ).createShader(bounds),
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            'Privacy Policy.',
                            style: AppTypography.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Consent box
                  _buildConsentBox(),

                  const SizedBox(height: 32),

                  // Continue button
                  _buildContinueButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithGlow() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD0D0D0).withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: const Color(0xFFD0D0D0).withOpacity(0.2),
            blurRadius: 80,
            spreadRadius: 20,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD0D0D0).withOpacity(0.6),
            width: 3,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: ClipOval(
          child: Image.asset('assets/icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  Widget _buildConsentBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0D0D0).withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Age checkbox
          _buildCheckboxRow(
            text: 'Yes, I am 18 years old or older.',
            value: _isOver18,
            onChanged: (v) => setState(() => _isOver18 = v),
          ),

          const SizedBox(height: 16),

          // Terms checkbox
          _buildCheckboxRow(
            text:
                'I have read and agree to Luxury Casino\'s Terms & Conditions and Privacy Policy.',
            value: _acceptTermsAndPrivacy,
            onChanged: (v) => setState(() => _acceptTermsAndPrivacy = v),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxRow({
    required String text,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checkbox
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.textTertiary,
                width: 1.5,
              ),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.black)
                : null,
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: value ? Colors.white : AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: GestureDetector(
        onTap: _canContinue ? _onContinue : null,
        child: Container(
          decoration: BoxDecoration(
            gradient: _canContinue
                ? const LinearGradient(
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
                  )
                : LinearGradient(
                    colors: [
                      const Color(0xFF909090).withOpacity(0.3),
                      const Color(0xFFB8B8B8).withOpacity(0.3),
                      const Color(0xFFD0D0D0).withOpacity(0.3),
                      const Color(0xFFB8B8B8).withOpacity(0.3),
                      const Color(0xFF909090).withOpacity(0.3),
                    ],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: _canContinue
                ? [
                    BoxShadow(
                      color: const Color(0xFFD0D0D0).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              'CONFIRM AND CONTINUE',
              style: AppTypography.buttonLarge.copyWith(
                color: _canContinue ? Colors.black : Colors.black.withOpacity(0.5),
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
