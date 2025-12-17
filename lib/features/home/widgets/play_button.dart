import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

class PlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const PlayButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<PlayButton> createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _glareController;
  late Animation<double> _glowAnimation;
  late Animation<double> _glareAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 20, end: 32).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Glare effect animation
    _glareController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glareAnimation = Tween<double>(begin: -1.0, end: 2.5).animate(
      CurvedAnimation(parent: _glareController, curve: Curves.easeInOut),
    );

    // Start glare animation after 1000ms delay
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _glareController.repeat(period: const Duration(milliseconds: 3000));
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _glareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowController, _glareController]),
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.95 : 1.0,
            child: SizedBox(
              width: 200,
              height: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.full),
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      width: 200,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppGradients.cyanButtonGradient,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGlow.withOpacity(
                              0.4 + (_glowAnimation.value - 20) / 60,
                            ),
                            blurRadius: _glowAnimation.value,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PLAY NOW',
                            style: AppTypography.buttonLarge.copyWith(
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Glare effect
                    Positioned(
                      left: (_glareAnimation.value * 100) - 50,
                      top: -100,
                      child: Transform.rotate(
                        angle: -0.6,
                        child: Container(
                          width: 60,
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(1.0),
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
