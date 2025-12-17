import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/audio_service.dart';
import '../../../shared/widgets/webview_screen.dart';
import '../../../shared/widgets/age_notice.dart';
import '../widgets/contact_us_modal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final soundEnabled = ref.watch(soundEnabledProvider);
    final vibrationEnabled = ref.watch(vibrationEnabledProvider);
    final audioService = ref.watch(audioServiceProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top padding for status bar area (content scrolls under gradient)
          SizedBox(height: topPadding + 20),

          // Page Header (matching Home & Games style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: AppTypography.headingLarge.copyWith(
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your experience',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Preferences Section
            _buildSectionHeader(context, title: 'Preferences'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSettingsCard([
                _buildToggleTile(
                  icon: Icons.volume_up_rounded,
                  title: AppStrings.soundEffects,
                  value: soundEnabled,
                  onChanged: (value) {
                    ref.read(soundEnabledProvider.notifier).setValue(value);
                    // Play a tap sound to demonstrate
                    if (value) {
                      audioService.playTapSound(enabled: true);
                    }
                  },
                ),
                _buildToggleTile(
                  icon: Icons.vibration_rounded,
                  title: AppStrings.vibration,
                  value: vibrationEnabled,
                  onChanged: (value) {
                    ref.read(vibrationEnabledProvider.notifier).setValue(value);
                    // Demonstrate vibration when enabled
                    if (value) {
                      audioService.lightVibrate(enabled: true);
                    }
                  },
                  showDivider: false,
                ),
              ]),
            ),

            const SizedBox(height: 32),

            // Support Section
            _buildSectionHeader(context, title: 'Support'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSettingsCard([
                _buildNavigationTile(
                  context: context,
                  icon: Icons.mail_rounded,
                  title: AppStrings.contactUs,
                  onTap: () {
                    audioService.playTapSound(enabled: soundEnabled);
                    audioService.lightVibrate(enabled: vibrationEnabled);
                    ContactUsModal.show(context);
                  },
                  showDivider: false,
                ),
              ]),
            ),

            const SizedBox(height: 32),

            // Legal Section
            _buildSectionHeader(context, title: 'Legal'),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSettingsCard([
                _buildNavigationTile(
                  context: context,
                  icon: Icons.description_rounded,
                  title: AppStrings.termsOfService,
                  onTap: () {
                    audioService.playTapSound(enabled: soundEnabled);
                    audioService.lightVibrate(enabled: vibrationEnabled);
                    WebViewScreen.open(
                      context,
                      url: 'https://luxuryloungecasinoapp.com/terms-and-conditions/',
                      title: 'Terms of Service',
                    );
                  },
                ),
                _buildNavigationTile(
                  context: context,
                  icon: Icons.privacy_tip_rounded,
                  title: AppStrings.privacyPolicy,
                  onTap: () {
                    audioService.playTapSound(enabled: soundEnabled);
                    audioService.lightVibrate(enabled: vibrationEnabled);
                    WebViewScreen.open(
                      context,
                      url: 'https://luxuryloungecasinoapp.com/privacy-policy/',
                      title: 'Privacy Policy',
                    );
                  },
                  showDivider: false,
                ),
              ]),
            ),

          const SizedBox(height: 24),

          // Age Notice
          const AgeNotice(),

          // Bottom padding for navbar
          SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
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
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD0D0D0).withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: AppTypography.headingSmall.copyWith(
              fontSize: 18,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withOpacity(0.3),
                inactiveThumbColor: Colors.white.withOpacity(0.5),
                inactiveTrackColor: Colors.white.withOpacity(0.1),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: showDivider ? null : BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.2),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(icon, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: Colors.white.withOpacity(0.05),
          ),
      ],
    );
  }
}
