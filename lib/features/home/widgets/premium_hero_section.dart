import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';

class PremiumHeroSection extends StatefulWidget {
  final VoidCallback onPlayPressed;

  const PremiumHeroSection({
    super.key,
    required this.onPlayPressed,
  });

  @override
  State<PremiumHeroSection> createState() => _PremiumHeroSectionState();
}

class _PremiumHeroSectionState extends State<PremiumHeroSection>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _entranceController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the glow
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotate animation for decorative elements
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Entrance animation
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          // Rotating decorative rings
          _buildRotatingRings(screenWidth),

          // Radial glow behind logo
          _buildRadialGlow(),

          // Floating particles
          _buildFloatingParticles(),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _entranceController,
                _pulseController,
              ]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: _slideAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App name with shimmer
                        _buildAppName(),

                        const SizedBox(height: 8),

                        // Subtitle with decorative lines
                        _buildSubtitle(),

                        const SizedBox(height: 24),

                        // Premium play button
                        _buildPlayButton(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Top decorative light beams
          _buildLightBeams(),
        ],
      ),
    );
  }

  Widget _buildRotatingRings(double screenWidth) {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return Center(
          child: Transform.rotate(
            angle: _rotateController.value * math.pi * 2,
            child: Container(
              width: screenWidth * 0.8,
              height: screenWidth * 0.8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Inner ring
                  Center(
                    child: Container(
                      width: screenWidth * 0.6,
                      height: screenWidth * 0.6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.08),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  // Dots on the ring
                  for (int i = 0; i < 8; i++)
                    Positioned(
                      left: screenWidth * 0.4 + 
                          screenWidth * 0.35 * math.cos(i * math.pi / 4),
                      top: screenWidth * 0.4 + 
                          screenWidth * 0.35 * math.sin(i * math.pi / 4),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadialGlow() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withOpacity(0.15 * _pulseAnimation.value),
                  AppColors.primary.withOpacity(0.05 * _pulseAnimation.value),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingParticles() {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlesPainter(
          animation: _rotateController,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildAppName() {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8A8A8A),   // Dark edge
            Color(0xFFB0B0B0),   // Medium
            Color(0xFFD8D8D8),   // Light
            Color(0xFFFFFFFF),   // Bright center highlight
            Color(0xFFF0F0F0),   // Near white
            Color(0xFFD0D0D0),   // Light
            Color(0xFFB0B0B0),   // Medium
            Color(0xFF909090),   // Dark edge
          ],
          stops: [0.0, 0.15, 0.3, 0.45, 0.55, 0.7, 0.85, 1.0],
        ).createShader(bounds);
      },
      child: Text(
        AppStrings.appName,
        style: AppTypography.displayLarge.copyWith(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: 8,
          shadows: [
            Shadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 30,
            ),
            Shadow(
              color: AppColors.silverDark.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecorativeLine(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            AppStrings.appSubtitle,
            style: AppTypography.bodySmall.copyWith(
              letterSpacing: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        _buildDecorativeLine(reverse: true),
      ],
    );
  }

  Widget _buildDecorativeLine({bool reverse = false}) {
    return Container(
      width: 50,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reverse ? Alignment.centerLeft : Alignment.centerRight,
          end: reverse ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            const Color(0xFFD0D0D0),
            const Color(0xFFB0B0B0).withOpacity(0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: widget.onPlayPressed,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
            decoration: BoxDecoration(
              // Realistic silver metallic gradient with bright center
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF909090),   // Dark edge
                  Color(0xFFB8B8B8),   // Medium
                  Color(0xFFE0E0E0),   // Light
                  Color(0xFFFFFFFF),   // Bright center highlight
                  Color(0xFFF5F5F5),   // Near white
                  Color(0xFFD8D8D8),   // Light
                  Color(0xFFB0B0B0),   // Medium
                  Color(0xFF888888),   // Dark edge
                ],
                stops: [0.0, 0.12, 0.3, 0.45, 0.55, 0.7, 0.88, 1.0],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: const Color(0xFFD0D0D0),
                width: 1,
              ),
              boxShadow: [
                // Bright inner highlight
                BoxShadow(
                  color: Colors.white.withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
                // Outer metallic glow
                BoxShadow(
                  color: const Color(0xFFB0B0B0).withOpacity(0.3 + _pulseAnimation.value * 0.2),
                  blurRadius: 30 + (_pulseAnimation.value * 15),
                  spreadRadius: -2,
                ),
                // Drop shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 25,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Play icon - dark on light gradient
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF2A2A2A),
                  size: 32,
                ),
                const SizedBox(width: 8),
                // Text - dark on light gradient
                Text(
                  'PLAY NOW',
                  style: AppTypography.labelLarge.copyWith(
                    color: const Color(0xFF2A2A2A),
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLightBeams() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 200,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1),
                radius: 1.5,
                colors: [
                  AppColors.primary.withOpacity(0.1 * _pulseAnimation.value),
                  Colors.transparent,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final Animation<double> animation;

  _ParticlesPainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // Fixed seed for consistent particles
    
    for (int i = 0; i < 30; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final particleSize = random.nextDouble() * 2 + 1;
      final opacity = random.nextDouble() * 0.3 + 0.1;
      final speed = random.nextDouble() * 0.5 + 0.5;
      
      final progress = (animation.value * speed) % 1.0;
      final y = (baseY + progress * 100) % size.height;
      final x = baseX + math.sin(progress * math.pi * 2 + i) * 20;

      final paint = Paint()
        ..color = (random.nextDouble() > 0.7 ? AppColors.primary : Colors.white)
            .withOpacity(opacity * (1 - (y / size.height - 0.5).abs()))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, particleSize);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
