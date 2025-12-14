import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class MysteriousWelcomeBanner extends StatelessWidget {
  const MysteriousWelcomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _BannerContent(),
    );
  }
}

class _BannerContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A1520),
                const Color(0xFF051015),
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Central glow
              Center(
                child: Container(
                  width: 280,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.12),
                        AppColors.primary.withOpacity(0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),

              // Content with staggered animations
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top tagline - animated
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD4D4D4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC0C0C0).withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'YOUR MOMENT IS NOW',
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFD4D4D4),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC0C0C0).withOpacity(0.6),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Main hype text with scale animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.5 + (0.5 * value),
                          child: Opacity(
                            opacity: value.clamp(0.0, 1.0),
                            child: child,
                          ),
                        );
                      },
                      child: ShaderMask(
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
                        blendMode: BlendMode.srcIn,
                        child: Text(
                          'FEEL THE RUSH',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.white.withOpacity(0.3),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Divider with diamond - expanding animation
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60 * value,
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.silver.withOpacity(0.8),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Opacity(
                              opacity: value,
                              child: Transform.rotate(
                                angle: math.pi / 4,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.silver,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.silver.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 60 * value,
                              height: 1,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.silver.withOpacity(0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Tagline - slide up
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 15 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        'FORTUNE FAVORS THE BOLD',
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFC0C0C0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Top shine line
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 2000),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.silverMedium.withOpacity(0.5 * value),
                            AppColors.silverLight.withOpacity(0.7 * value),
                            AppColors.silverMedium.withOpacity(0.5 * value),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Corner brackets
              _AnimatedCorners(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedCorners extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Stack(
          children: [
            Positioned(top: 12, left: 12, child: _corner(value)),
            Positioned(top: 12, right: 12, child: Transform.scale(scaleX: -1, child: _corner(value))),
            Positioned(bottom: 12, left: 12, child: Transform.scale(scaleY: -1, child: _corner(value))),
            Positioned(bottom: 12, right: 12, child: Transform.scale(scaleX: -1, scaleY: -1, child: _corner(value))),
          ],
        );
      },
    );
  }

  Widget _corner(double opacity) {
    return Opacity(
      opacity: opacity * 0.5,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _CornerPainter(),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.silver.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..lineTo(0, 0)
      ..lineTo(size.width * 0.5, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
