import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/premium_game_card.dart';
import '../../../shared/widgets/effects.dart';
import '../providers/games_provider.dart';
import '../models/game.dart';

class GameGrid extends ConsumerStatefulWidget {
  final Function(Game)? onGameTap;

  const GameGrid({
    super.key,
    this.onGameTap,
  });

  @override
  ConsumerState<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends ConsumerState<GameGrid>
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
    final gamesAsync = ref.watch(filteredGamesProvider);

    return gamesAsync.when(
      data: (games) => GridView.builder(
        padding: EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.lg,
          bottom: 120 + MediaQuery.of(context).padding.bottom,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          // Staggered animation for each card
          return AnimatedBuilder(
            animation: _staggerController,
            builder: (context, child) {
              // Calculate stagger based on row and column
              final row = index ~/ 2;
              final col = index % 2;
              final delay = (row * 0.05 + col * 0.025).clamp(0.0, 0.7);
              final endDelay = (delay + 0.3).clamp(0.0, 1.0);
              
              final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _staggerController,
                  curve: Interval(delay, endDelay, curve: Curves.easeOut),
                ),
              );
              final slide = Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: _staggerController,
                  curve: Interval(delay, endDelay, curve: Curves.easeOut),
                ),
              );
              final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
                CurvedAnimation(
                  parent: _staggerController,
                  curve: Interval(delay, endDelay, curve: Curves.easeOut),
                ),
              );
              
              return Opacity(
                opacity: opacity.value,
                child: Transform.translate(
                  offset: slide.value,
                  child: Transform.scale(
                    scale: scale.value,
                    child: PremiumGameCard(
                      game: game,
                      onTap: () => widget.onGameTap?.call(game),
                      showBorder: true,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      loading: () => GridView.builder(
        padding: EdgeInsets.only(
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
          top: AppSpacing.lg,
          bottom: 120 + MediaQuery.of(context).padding.bottom,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return ShimmerEffect(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.1),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load games',
              style: AppTypography.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Please check your connection and try again',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                // Refresh
                ref.invalidate(filteredGamesProvider);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF00A5B5)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.refresh_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Retry',
                      style: AppTypography.labelMedium.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
