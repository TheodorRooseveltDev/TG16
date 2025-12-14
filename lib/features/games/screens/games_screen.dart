import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../providers/games_provider.dart';
import '../../../shared/widgets/premium_game_card.dart';
import '../../../shared/widgets/effects.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedGamesAsync = ref.watch(animatedGamesProvider);
    final allGamesAsync = ref.watch(gamesProvider);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Page Header (like before)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Games',
                    style: AppTypography.headingLarge.copyWith(
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover premium casino games',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 28),

            // Premium Games Section (animated)
            _buildSectionHeader(context, title: 'Premium Games'),
            const SizedBox(height: 16),
            _buildAnimatedGamesCarousel(animatedGamesAsync),

            const SizedBox(height: 32),

            // All Games Section
            _buildSectionHeader(context, title: 'Slots'),
            const SizedBox(height: 16),
            _buildGamesCarousel(allGamesAsync, 10, 20),

            const SizedBox(height: 32),

            // More Games
            _buildSectionHeader(context, title: 'Popular'),
            const SizedBox(height: 16),
            _buildGamesCarousel(allGamesAsync, 20, 30),

            const SizedBox(height: 32),

            // Even More Games
            _buildSectionHeader(context, title: 'New Games'),
            const SizedBox(height: 16),
            _buildGamesCarousel(allGamesAsync, 30, 40),

            // Bottom padding for navbar
            SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
          ],
        ),
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
              letterSpacing: 0.5,
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
        data: (games) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: games.length,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(right: index < games.length - 1 ? 16 : 0),
            child: PremiumGameCard(
              game: games[index],
              width: 180,
              height: 240,
              onTap: () {
                context.push('/game/${games[index].id}', extra: games[index]);
              },
            ),
          ),
        ),
        loading: () => _buildLoadingCarousel(),
        error: (_, __) => const Center(child: Text('Error loading games')),
      ),
    );
  }

  Widget _buildGamesCarousel(AsyncValue allGamesAsync, int start, int end) {
    return SizedBox(
      height: 240,
      child: allGamesAsync.when(
        data: (games) {
          final subset = games.skip(start).take(end - start).toList();
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: subset.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(right: index < subset.length - 1 ? 16 : 0),
              child: PremiumGameCard(
                game: subset[index],
                width: 180,
                height: 240,
                onTap: () {
                  context.push('/game/${subset[index].id}', extra: subset[index]);
                },
              ),
            ),
          );
        },
        loading: () => _buildLoadingCarousel(),
        error: (_, __) => const Center(child: Text('Error loading games')),
      ),
    );
  }

  Widget _buildLoadingCarousel() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
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
      ),
    );
  }
}
