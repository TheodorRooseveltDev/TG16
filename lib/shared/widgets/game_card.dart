import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../features/games/models/game.dart';

class GameCard extends StatefulWidget {
  final Game game;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTagColor(String? tag) {
    switch (tag) {
      case 'NEW':
        return AppColors.tagNew;
      case 'HOT':
        return AppColors.tagHot;
      case 'EXCLUSIVE':
        return AppColors.tagExclusive;
      case 'FEATURED':
        return AppColors.tagFeatured;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            boxShadow: AppShadows.cardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Game Image
              Image.asset(
                widget.game.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.backgroundTertiary,
                    child: const Icon(
                      Icons.casino,
                      size: 40,
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),

              // Gradient overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 60,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppGradients.cardOverlayGradient,
                  ),
                ),
              ),

              // Game name
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  widget.game.name,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Tag badge
              if (widget.game.tag != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getTagColor(widget.game.tag),
                      borderRadius: BorderRadius.circular(AppRadius.xs),
                    ),
                    child: Text(
                      widget.game.tag!,
                      style: AppTypography.tag,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
