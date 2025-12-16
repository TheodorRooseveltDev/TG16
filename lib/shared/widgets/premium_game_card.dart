import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme.dart';
import '../../core/services/audio_service.dart';
import '../../features/games/models/game.dart';

class PremiumGameCard extends ConsumerStatefulWidget {
  final Game game;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const PremiumGameCard({
    super.key,
    required this.game,
    this.onTap,
    this.width = 160,
    this.height = 220,
  });

  @override
  ConsumerState<PremiumGameCard> createState() => _PremiumGameCardState();
}

class _PremiumGameCardState extends ConsumerState<PremiumGameCard>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
    
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _pressController.reverse();

    // Play tap sound and vibrate
    final audioService = ref.read(audioServiceProvider);
    final soundEnabled = ref.read(soundEnabledProvider);
    final vibrationEnabled = ref.read(vibrationEnabledProvider);
    audioService.playTapSound(enabled: soundEnabled);
    audioService.lightVibrate(enabled: vibrationEnabled);

    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _pressController.reverse();
  }

  Widget _buildGameImage() {
    final imageUrl = widget.game.displayIcon;

    // Check if it's a network URL
    if (imageUrl.isNotEmpty && Game.isNetworkUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.backgroundCard,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.backgroundCard,
          child: const Center(
            child: Icon(Icons.casino, size: 40, color: Color(0xFFD0D0D0)),
          ),
        ),
      );
    }

    // Fallback to asset image (legacy support)
    if (imageUrl.isNotEmpty) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.backgroundCard,
            child: const Center(
              child: Icon(Icons.casino, size: 40, color: Color(0xFFD0D0D0)),
            ),
          );
        },
      );
    }

    // No image available
    return Container(
      color: AppColors.backgroundCard,
      child: const Center(
        child: Icon(Icons.casino, size: 40, color: Color(0xFFD0D0D0)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pressController, _glowController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFFD0D0D0).withOpacity(
                      0.1 + (_glowAnimation.value * 0.15),
                    ),
                    blurRadius: 25 + (_glowAnimation.value * 10),
                    spreadRadius: -2,
                  ),
                  if (_isPressed)
                    BoxShadow(
                      color: const Color(0xFFD0D0D0).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Game image
                    _buildGameImage(),
                    // Bottom gradient
                    Positioned(
                      left: 0, right: 0, bottom: 0, height: 100,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                              Colors.black.withOpacity(0.95),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Game name & play button
                    Positioned(
                      left: 14, right: 14, bottom: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.game.name,
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.black),
                                const SizedBox(width: 4),
                                Text(
                                  'Play',
                                  style: AppTypography.labelMedium.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Border glow - Silver metallic with gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color.lerp(
                              const Color(0xFF808080),
                              const Color(0xFFD0D0D0),
                              _glowAnimation.value,
                            )!.withOpacity(0.5 + (_glowAnimation.value * 0.2)),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05 * _glowAnimation.value),
                              blurRadius: 8,
                              spreadRadius: -2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Large featured card with more details
class FeaturedGameCard extends ConsumerStatefulWidget {
  final Game game;
  final VoidCallback? onTap;

  const FeaturedGameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  ConsumerState<FeaturedGameCard> createState() => _FeaturedGameCardState();
}

class _FeaturedGameCardState extends ConsumerState<FeaturedGameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Widget _buildFeaturedImage() {
    final imageUrl = widget.game.displayIcon;

    // Check if it's a network URL
    if (imageUrl.isNotEmpty && Game.isNetworkUrl(imageUrl)) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD0D0D0).withOpacity(0.3),
                AppColors.backgroundCard,
              ],
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFD0D0D0).withOpacity(0.3),
                AppColors.backgroundCard,
              ],
            ),
          ),
        ),
      );
    }

    // Fallback to asset image (legacy support)
    if (imageUrl.isNotEmpty) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFD0D0D0).withOpacity(0.3),
                  AppColors.backgroundCard,
                ],
              ),
            ),
          );
        },
      );
    }

    // No image available
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD0D0D0).withOpacity(0.3),
            AppColors.backgroundCard,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            // Play tap sound and vibrate
            final audioService = ref.read(audioServiceProvider);
            final soundEnabled = ref.read(soundEnabledProvider);
            final vibrationEnabled = ref.read(vibrationEnabledProvider);
            audioService.playTapSound(enabled: soundEnabled);
            audioService.lightVibrate(enabled: vibrationEnabled);

            widget.onTap?.call();
          },
          child: Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: const Color(0xFFD0D0D0).withOpacity(
                    0.2 + (_glowController.value * 0.15),
                  ),
                  blurRadius: 40,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  _buildFeaturedImage(),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0.9),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Featured badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFFA500),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withOpacity(0.4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'FEATURED',
                                style: AppTypography.caption.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Game name
                        Text(
                          widget.game.name,
                          style: AppTypography.headingMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        // Play button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                Color(0xFF00A5B5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Play Now',
                                style: AppTypography.labelMedium.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Animated border glow - Silver metallic with gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Color.lerp(
                            const Color(0xFF808080),
                            const Color(0xFFD0D0D0),
                            _glowController.value,
                          )!.withOpacity(0.4 + (_glowController.value * 0.2)),
                          width: 1,
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
    );
  }
}
