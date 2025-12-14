import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme.dart';
import '../../games/providers/games_provider.dart';
import '../../../shared/widgets/premium_game_card.dart';

class QuickPlayChips extends ConsumerStatefulWidget {
  final Function(String)? onCategorySelected;

  const QuickPlayChips({
    super.key,
    this.onCategorySelected,
  });

  @override
  ConsumerState<QuickPlayChips> createState() => _QuickPlayChipsState();
}

class _QuickPlayChipsState extends ConsumerState<QuickPlayChips>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get games starting from index 10 to show different games
    final gamesAsync = ref.watch(gamesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        AnimatedBuilder(
          animation: _entranceController,
          builder: (context, child) {
            final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _entranceController,
                curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
              ),
            );
            return Opacity(
              opacity: opacity.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
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
                      'Quick Play',
                      style: AppTypography.headingSmall.copyWith(
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        // Games carousel
        SizedBox(
          height: 240,
          child: gamesAsync.when(
            data: (games) {
              // Skip first 16 games to show different ones
              final quickPlayGames = games.skip(16).take(10).toList();
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                itemCount: quickPlayGames.length,
                itemBuilder: (context, index) {
                  final game = quickPlayGames[index];
                  return AnimatedBuilder(
                    animation: _entranceController,
                    builder: (context, child) {
                      final startInterval = 0.2 + (index * 0.08);
                      final endInterval = (startInterval + 0.3).clamp(0.0, 1.0);
                      final opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
                        ),
                      );
                      final slide = Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
                        CurvedAnimation(
                          parent: _entranceController,
                          curve: Interval(startInterval, endInterval, curve: Curves.easeOut),
                        ),
                      );
                      return Opacity(
                        opacity: opacity.value,
                        child: Transform.translate(
                          offset: slide.value,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: index < quickPlayGames.length - 1 ? AppSpacing.cardGap : 0,
                            ),
                            child: PremiumGameCard(
                              game: game,
                              width: 180,
                              height: 240,
                              onTap: () {
                                context.push('/game/${game.id}', extra: game);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
