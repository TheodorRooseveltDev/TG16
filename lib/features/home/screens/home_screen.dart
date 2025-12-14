import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/widgets.dart';
import '../widgets/premium_hero_section.dart';
import '../widgets/mysterious_welcome_banner.dart';
import '../../games/providers/games_provider.dart';
import '../../../shared/widgets/premium_game_card.dart';
import '../../../shared/widgets/effects.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToGames;

  const HomeScreen({
    super.key,
    required this.onNavigateToGames,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedGamesAsync = ref.watch(animatedGamesProvider);
    final staticGamesAsync = ref.watch(staticGamesProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top padding for status bar area (content scrolls under it)
          SizedBox(height: topPadding + 8),

          // Mysterious Welcome Banner - The Special Sauce
          const MysteriousWelcomeBanner(),

          const SizedBox(height: AppSpacing.lg),

          // Premium Hero Section with Play Button
          PremiumHeroSection(
            onPlayPressed: onNavigateToGames,
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // Animated Games Section (Premium)
            _buildSectionHeader(
              context,
              title: 'Premium Games',
              onSeeAll: onNavigateToGames,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildAnimatedGamesCarousel(animatedGamesAsync),

            const SizedBox(height: AppSpacing.sectionGap),

            // Static Games Section
            _buildSectionHeader(
              context,
              title: 'More Games',
              onSeeAll: onNavigateToGames,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildStaticGamesCarousel(staticGamesAsync),

            const SizedBox(height: AppSpacing.sectionGap),

            // Quick Play Category Chips
            const QuickPlayChips(),

            // Bottom padding for floating navbar
            SizedBox(
              height: 120 + MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
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
                title,
                style: AppTypography.headingSmall.copyWith(
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
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
    );
  }

  Widget _buildAnimatedGamesCarousel(AsyncValue animatedGamesAsync) {
    return SizedBox(
      height: 240,
      child: animatedGamesAsync.when(
        data: (games) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < games.length - 1 ? AppSpacing.cardGap : 0,
                ),
                child: PremiumGameCard(
                  game: game,
                  width: 180,
                  height: 240,
                  onTap: () {
                    context.push('/game/${game.id}', extra: game);
                  },
                ),
              );
            },
          );
        },
        loading: () => _buildLoadingCarousel(),
        error: (_, __) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildStaticGamesCarousel(AsyncValue staticGamesAsync) {
    return SizedBox(
      height: 240,
      child: staticGamesAsync.when(
        data: (games) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            itemCount: games.length > 10 ? 10 : games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < games.length - 1 ? AppSpacing.cardGap : 0,
                ),
                child: PremiumGameCard(
                  game: game,
                  width: 180,
                  height: 240,
                  onTap: () {
                    context.push('/game/${game.id}', extra: game);
                  },
                ),
              );
            },
          );
        },
        loading: () => _buildLoadingCarousel(),
        error: (_, __) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildLoadingCarousel() {
    return ListView.builder(
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
              width: 180,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        'Error loading games',
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}
