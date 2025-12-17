import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';
import '../widgets/widgets.dart';
import '../widgets/premium_hero_section.dart';
import '../widgets/mysterious_welcome_banner.dart';
import '../../games/providers/games_provider.dart';
import '../../../shared/widgets/premium_game_card.dart';
import '../../../shared/widgets/effects.dart';
import '../../../shared/widgets/age_notice.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToGames;

  const HomeScreen({
    super.key,
    required this.onNavigateToGames,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ScrollController _animatedGamesScrollController;
  late ScrollController _staticGamesScrollController;
  Timer? _animatedScrollTimer;
  Timer? _staticScrollTimer;
  Timer? _animatedResumeTimer;
  Timer? _staticResumeTimer;
  bool _isAnimatedManualScrolling = false;
  bool _isStaticManualScrolling = false;

  @override
  void initState() {
    super.initState();
    _animatedGamesScrollController = ScrollController();
    _staticGamesScrollController = ScrollController();
    
    // Start auto-scroll after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  void _onAnimatedScrollStart() {
    _isAnimatedManualScrolling = true;
    _animatedScrollTimer?.cancel();
    _animatedResumeTimer?.cancel();
  }

  void _onAnimatedScrollEnd() {
    _animatedResumeTimer?.cancel();
    _animatedResumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _isAnimatedManualScrolling = false;
        _startAnimatedAutoScroll();
      }
    });
  }

  void _onStaticScrollStart() {
    _isStaticManualScrolling = true;
    _staticScrollTimer?.cancel();
    _staticResumeTimer?.cancel();
  }

  void _onStaticScrollEnd() {
    _staticResumeTimer?.cancel();
    _staticResumeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        _isStaticManualScrolling = false;
        _startStaticAutoScroll();
      }
    });
  }

  void _startAutoScroll() {
    _startAnimatedAutoScroll();
    _startStaticAutoScroll();
  }

  void _startAnimatedAutoScroll() {
    _animatedScrollTimer?.cancel();
    // Auto-scroll for animated games carousel
    _animatedScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted || !_animatedGamesScrollController.hasClients || _isAnimatedManualScrolling) return;
      
      final maxScroll = _animatedGamesScrollController.position.maxScrollExtent;
      final currentScroll = _animatedGamesScrollController.offset;
      
      if (currentScroll >= maxScroll) {
        _animatedGamesScrollController.jumpTo(0);
      } else {
        _animatedGamesScrollController.jumpTo(currentScroll + 1);
      }
    });
  }

  void _startStaticAutoScroll() {
    _staticScrollTimer?.cancel();
    // Auto-scroll for static games carousel (slightly slower)
    _staticScrollTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted || !_staticGamesScrollController.hasClients || _isStaticManualScrolling) return;
      
      final maxScroll = _staticGamesScrollController.position.maxScrollExtent;
      final currentScroll = _staticGamesScrollController.offset;
      
      if (currentScroll >= maxScroll) {
        _staticGamesScrollController.jumpTo(0);
      } else {
        _staticGamesScrollController.jumpTo(currentScroll + 1);
      }
    });
  }

  @override
  void dispose() {
    _animatedScrollTimer?.cancel();
    _staticScrollTimer?.cancel();
    _animatedResumeTimer?.cancel();
    _staticResumeTimer?.cancel();
    _animatedGamesScrollController.dispose();
    _staticGamesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animatedGamesAsync = ref.watch(animatedGamesProvider);
    final staticGamesAsync = ref.watch(staticGamesProvider);
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top padding for status bar area (content scrolls under it)
          SizedBox(height: topPadding + 8),

          // Premium Hero Section with Play Button
          PremiumHeroSection(
            onPlayPressed: widget.onNavigateToGames,
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // Animated Games Section (Premium)
            _buildSectionHeader(
              context,
              title: 'Premium Games',
              onSeeAll: widget.onNavigateToGames,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildAnimatedGamesCarousel(animatedGamesAsync),

            const SizedBox(height: AppSpacing.sectionGap),

            // Hot Games Promo Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFC0C0C0).withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: const Color(0xFFC0C0C0).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image
                      Image.asset(
                        'assets/images/cardimg-min.jpeg',
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay (top-left corner)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 350,
                          height: 200,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.2,
                              colors: [
                                Colors.black.withOpacity(0.95),
                                Colors.black.withOpacity(0.8),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.0),
                              ],
                              stops: const [0.0, 0.35, 0.65, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Text content
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hot Games',
                              style: AppTypography.headingLarge.copyWith(
                                letterSpacing: 1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'The newest and most saught after games!',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // Static Games Section
            _buildSectionHeader(
              context,
              title: 'More Games',
              onSeeAll: widget.onNavigateToGames,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildStaticGamesCarousel(staticGamesAsync),

            const SizedBox(height: AppSpacing.sectionGap),

            // Quick Play Category Chips
            const QuickPlayChips(),

            const SizedBox(height: AppSpacing.lg),

            // Age Notice
            const AgeNotice(),

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
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                if (notification.dragDetails != null) {
                  _onAnimatedScrollStart();
                }
              } else if (notification is ScrollEndNotification) {
                _onAnimatedScrollEnd();
              }
              return false;
            },
            child: ListView.builder(
              controller: _animatedGamesScrollController,
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
          ),
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
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                if (notification.dragDetails != null) {
                  _onStaticScrollStart();
                }
              } else if (notification is ScrollEndNotification) {
                _onStaticScrollEnd();
              }
              return false;
            },
            child: ListView.builder(
              controller: _staticGamesScrollController,
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
          ),
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
