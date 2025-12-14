import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/premium_game_card.dart';
import '../../../shared/widgets/effects.dart';
import '../../games/providers/games_provider.dart';
import '../../games/models/game.dart';

class FeaturedGamesCarousel extends ConsumerStatefulWidget {
  final VoidCallback? onSeeAll;
  final Function(Game)? onGameTap;

  const FeaturedGamesCarousel({
    super.key,
    this.onSeeAll,
    this.onGameTap,
  });

  @override
  ConsumerState<FeaturedGamesCarousel> createState() => _FeaturedGamesCarouselState();
}

class _FeaturedGamesCarouselState extends ConsumerState<FeaturedGamesCarousel>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredGamesAsync = ref.watch(featuredGamesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with animated entrance
        AnimatedBuilder(
          animation: _staggerController,
          builder: (context, child) {
            final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _staggerController,
                curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
              ),
            );
            final slide = Tween<Offset>(begin: const Offset(-20, 0), end: Offset.zero).animate(
              CurvedAnimation(
                parent: _staggerController,
                curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
              ),
            );
            return Opacity(
              opacity: opacity.value,
              child: Transform.translate(
                offset: slide.value,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                            AppStrings.featured,
                            style: AppTypography.headingSmall.copyWith(
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      if (widget.onSeeAll != null)
                        GestureDetector(
                          onTap: widget.onSeeAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFD0D0D0).withOpacity(0.1),
                                  const Color(0xFFFFFFFF).withOpacity(0.05),
                                ],
                              ),
                              border: Border.all(
                                color: const Color(0xFFD0D0D0).withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ShaderMask(
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
                                    AppStrings.seeAll,
                                    style: AppTypography.labelMedium,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                ShaderMask(
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
                                  child: const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 12,
                                  ),
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
        ),

        const SizedBox(height: AppSpacing.xl),

        // Featured game highlight (first game)
        featuredGamesAsync.when(
          data: (games) {
            if (games.isEmpty) return const SizedBox.shrink();
            
            return AnimatedBuilder(
              animation: _staggerController,
              builder: (context, child) {
                final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _staggerController,
                    curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
                  ),
                );
                final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _staggerController,
                    curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                  ),
                );
                return Opacity(
                  opacity: opacity.value,
                  child: Transform.scale(
                    scale: scale.value,
                    child: FeaturedGameCard(
                      game: games.first,
                      onTap: () => widget.onGameTap?.call(games.first),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: AppSpacing.xl),

        // Carousel of other games
        SizedBox(
          height: 220,
          child: featuredGamesAsync.when(
            data: (games) {
              final remainingGames = games.skip(1).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: remainingGames.length,
                itemBuilder: (context, index) {
                  final game = remainingGames[index];
                  return AnimatedBuilder(
                    animation: _staggerController,
                    builder: (context, child) {
                      final startInterval = 0.3 + (index * 0.08);
                      final endInterval = (startInterval + 0.2).clamp(0.0, 1.0);
                      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _staggerController,
                          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
                        ),
                      );
                      final slide = Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
                        CurvedAnimation(
                          parent: _staggerController,
                          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
                        ),
                      );
                      return Opacity(
                        opacity: opacity.value,
                        child: Transform.translate(
                          offset: slide.value,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < remainingGames.length - 1 ? AppSpacing.cardGap : 0,
                            ),
                            child: PremiumGameCard(
                              game: game,
                              width: 160,
                              height: 220,
                              onTap: () => widget.onGameTap?.call(game),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < 3 ? AppSpacing.cardGap : 0,
                  ),
                  child: ShimmerEffect(
                    child: Container(
                      width: 160,
                      height: 220,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCard,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                );
              },
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error loading games',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
