import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../models/game.dart';
import '../providers/games_provider.dart';
import '../../../shared/widgets/premium_game_card.dart';
import '../../../shared/widgets/effects.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animatedGamesAsync = ref.watch(animatedGamesProvider);
    final staticGamesAsync = ref.watch(staticGamesProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top padding for status bar area (content scrolls under gradient)
          SizedBox(height: topPadding + 20),

          // Page Header
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

            // Premium Games Section (animated icons)
            _buildSectionHeader(context, title: 'Premium Games'),
            const SizedBox(height: 16),
            _buildAnimatedGamesCarousel(animatedGamesAsync),

            const SizedBox(height: 32),

            // Rest of games in sections
            staticGamesAsync.when(
              data: (games) => _buildGameSections(context, games),
              loading: () => _buildLoadingSection(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // Bottom padding for navbar
          SizedBox(height: 120 + MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildGameSections(BuildContext context, List<Game> games) {
    if (games.isEmpty) return const SizedBox.shrink();

    // Split games into chunks for different sections
    final sectionSize = (games.length / 3).ceil().clamp(1, 10);
    final sections = <MapEntry<String, List<Game>>>[];

    if (games.isNotEmpty) {
      sections.add(MapEntry('Slots', games.take(sectionSize).toList()));
    }
    if (games.length > sectionSize) {
      sections.add(MapEntry('Popular', games.skip(sectionSize).take(sectionSize).toList()));
    }
    if (games.length > sectionSize * 2) {
      sections.add(MapEntry('New Games', games.skip(sectionSize * 2).toList()));
    }

    return Column(
      children: sections.map((section) {
        return Column(
          children: [
            _buildSectionHeader(context, title: section.key),
            const SizedBox(height: 16),
            _buildGamesCarouselFromList(section.value),
            const SizedBox(height: 32),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildLoadingSection() {
    return Column(
      children: [
        _buildLoadingCarousel(),
        const SizedBox(height: 32),
        _buildLoadingCarousel(),
      ],
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

  Widget _buildGamesCarouselFromList(List<Game> games) {
    if (games.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: ListView.builder(
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
