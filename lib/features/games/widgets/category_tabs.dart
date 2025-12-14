import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/constants/app_strings.dart';

class CategoryTabs extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _glowController;
  final List<GlobalKey> _tabKeys = [];

  final List<_TabData> _categories = [
    _TabData(AppStrings.allGames, Icons.apps_rounded),
    _TabData(AppStrings.slots, Icons.casino_rounded),
    _TabData(AppStrings.liveCasino, Icons.live_tv_rounded),
    _TabData(AppStrings.tableGames, Icons.table_restaurant_rounded),
    _TabData(AppStrings.jackpots, Icons.emoji_events_rounded),
    _TabData(AppStrings.newGames, Icons.new_releases_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabKeys.addAll(List.generate(_categories.length, (_) => GlobalKey()));
    
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _scrollToTab(int index) {
    final key = _tabKeys[index];
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.5,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category.name == widget.selectedCategory;

          return GestureDetector(
            key: _tabKeys[index],
            onTap: () {
              widget.onCategoryChanged(category.name);
              _scrollToTab(index);
            },
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(
                    right: index < _categories.length - 1 ? 12 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.primary.withOpacity(0.1),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary.withOpacity(
                              0.5 + (_glowController.value * 0.3),
                            )
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(
                                0.15 + (_glowController.value * 0.1),
                              ),
                              blurRadius: 12,
                              spreadRadius: -2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        category.icon,
                        size: 18,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textTertiary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _TabData {
  final String name;
  final IconData icon;

  _TabData(this.name, this.icon);
}
