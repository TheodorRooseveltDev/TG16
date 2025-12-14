import 'package:flutter/material.dart';

class PremiumNavbar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PremiumNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<PremiumNavbar> createState() => _PremiumNavbarState();
}

class _PremiumNavbarState extends State<PremiumNavbar>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _indicatorController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 20 + MediaQuery.of(context).padding.bottom,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            height: 72,
            decoration: BoxDecoration(
              // Solid dark background instead of blur (works with WebViews)
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                width: 1.5,
                color: Color.lerp(
                  const Color(0xFF909090),
                  const Color(0xFFD0D0D0),
                  _glowAnimation.value,
                )!,
              ),
              boxShadow: [
                // Outer silver glow
                BoxShadow(
                  color: const Color(0xFFB0B0B0).withOpacity(_glowAnimation.value * 0.1),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
                // Main shadow
                BoxShadow(
                  color: Colors.black.withOpacity(0.8),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(36),
              child: Stack(
                children: [
                  // Subtle gradient overlay for premium feel
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Nav items
                  Row(
                    children: [
                      Expanded(
                        child: _NavItem(
                          icon: Icons.home_rounded,
                          activeIcon: Icons.home_rounded,
                          label: 'Home',
                          isActive: widget.currentIndex == 0,
                          onTap: () => widget.onTap(0),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          icon: Icons.grid_view_rounded,
                          activeIcon: Icons.grid_view_rounded,
                          label: 'Games',
                          isActive: widget.currentIndex == 1,
                          onTap: () => widget.onTap(1),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          icon: Icons.settings_outlined,
                          activeIcon: Icons.settings_rounded,
                          label: 'Settings',
                          isActive: widget.currentIndex == 2,
                          onTap: () => widget.onTap(2),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward().then((_) => _controller.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedScale(
          scale: widget.isActive ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: SizedBox(
            height: 72,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: ShaderMask(
                    shaderCallback: widget.isActive
                        ? (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFF00B8C8),
                                Color(0xFF00E5F5),
                                Color(0xFF00F5FF),
                                Color(0xFF00E5F5),
                                Color(0xFF00B8C8),
                              ],
                              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                            ).createShader(bounds)
                        : (bounds) => LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.5),
                                Colors.white.withOpacity(0.5),
                              ],
                            ).createShader(bounds),
                    blendMode: BlendMode.srcIn,
                    child: Icon(
                      widget.isActive ? widget.activeIcon : widget.icon,
                      size: widget.isActive ? 28 : 24,
                      shadows: widget.isActive
                          ? [
                              Shadow(
                                color: const Color(0xFF00F5FF).withOpacity(0.8),
                                blurRadius: 15,
                              ),
                              Shadow(
                                color: const Color(0xFF00D4E8).withOpacity(0.5),
                                blurRadius: 25,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: widget.isActive ? 11 : 10,
                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                    color: widget.isActive
                        ? const Color(0xFF00F5FF)
                        : Colors.white.withOpacity(0.5),
                    shadows: widget.isActive
                        ? [
                            Shadow(
                              color: const Color(0xFF00F5FF).withOpacity(0.8),
                              blurRadius: 12,
                            ),
                            Shadow(
                              color: const Color(0xFF00D4E8).withOpacity(0.5),
                              blurRadius: 20,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
