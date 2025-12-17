import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';
import 'play_button.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onPlayPressed;

  const HeroSection({
    super.key,
    required this.onPlayPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppGradients.heroGradient,
      ),
      child: Stack(
        children: [
          // Subtle grid pattern overlay
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Diamond/gem icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primaryDark.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.diamond_outlined,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),

                const SizedBox(height: 20),

                // LUXURY text
                Text(
                  AppStrings.appName,
                  style: AppTypography.displayLarge,
                ),

                const SizedBox(height: 4),

                // LOUNGE text
                Text(
                  AppStrings.appSubtitle,
                  style: AppTypography.displayLarge,
                ),

                const SizedBox(height: 16),

                // casino with decorative lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 1,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        AppStrings.appTagline,
                        style: AppTypography.bodySmall.copyWith(
                          letterSpacing: 8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 1,
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Play Now Button
                PlayButton(onPressed: onPlayPressed),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const gridSize = 30.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
