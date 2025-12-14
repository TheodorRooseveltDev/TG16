import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/theme/theme.dart';
import '../models/game.dart';

class GameDetailScreen extends StatefulWidget {
  final Game game;

  const GameDetailScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _contentController;
  late AnimationController _glowController;
  late Animation<double> _heroScaleAnimation;
  late Animation<double> _heroOpacityAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _contentOpacityAnimation;
  late Animation<double> _glowAnimation;

  WebViewController? _webViewController;
  bool _webViewReady = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initWebView();
  }

  void _setupAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);

    _heroScaleAnimation = Tween<double>(begin: 1.2, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    _heroOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _contentOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Start animations
    _heroController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _contentController.forward();
    });
  }

  Future<void> _initWebView() async {
    final svgPath = widget.game.animatedLogo;
    if (svgPath != null) {
      try {
        final svgContent = await rootBundle.loadString(svgPath);
        if (mounted) {
          _setupWebViewController(svgContent);
        }
      } catch (e) {
        debugPrint('Error loading SVG: $e');
      }
    }
  }

  void _setupWebViewController(String svgContent) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _webViewReady = true);
          },
        ),
      );

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 100%; height: 100%; overflow: hidden; background: transparent; }
    body { display: flex; align-items: center; justify-content: center; }
    svg { width: 100%; height: 100%; object-fit: contain; }
  </style>
</head>
<body>$svgContent</body>
</html>
''';

    controller.loadHtmlString(html);
    setState(() => _webViewController = controller);
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _playGame() {
    setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isPlaying) {
      return _buildGamePlayer();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // Hero Section with Game Preview
                _buildHeroSection(),

                // Content Section
                _buildContentSection(),
              ],
            ),
          ),

          // Back Button (fixed)
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildGamePlayer() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Game WebView
          WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..setBackgroundColor(Colors.black)
              ..loadRequest(Uri.parse(widget.game.iframe)),
          ),

          // Close Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => setState(() => _isPlaying = false),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroController,
      builder: (context, child) {
        return Opacity(
          opacity: _heroOpacityAnimation.value,
          child: Transform.scale(
            scale: _heroScaleAnimation.value,
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.42,
              width: double.infinity,
              child: Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      widget.game.image,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // Gradient Overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.7),
                            Colors.black,
                          ],
                          stops: const [0.0, 0.3, 0.7, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Game Info Row at bottom - Icon + Title + Description
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Game Icon/Logo
                        _buildGameIcon(),
                        
                        const SizedBox(width: 16),
                        
                        // Title and Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Game Title
                              Text(
                                widget.game.name,
                                style: AppTypography.headingLarge.copyWith(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              // Mini Description
                              Text(
                                'Premium Slot • High Volatility • 96.5% RTP',
                                style: AppTypography.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Provider Tag
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  '⭐ FEATURED',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cyan glow line at bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, _) {
                        return Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.primary.withOpacity(_glowAnimation.value),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(_glowAnimation.value * 0.5),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameIcon() {
    // If animated logo exists and webview is ready, show animated version
    if (widget.game.animatedLogo != null && _webViewController != null && _webViewReady) {
      return Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: WebViewWidget(controller: _webViewController!),
        ),
      );
    }
    
    // Fallback to static image
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          widget.game.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return SlideTransition(
      position: _contentSlideAnimation,
      child: FadeTransition(
        opacity: _contentOpacityAnimation,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 24,
            right: 0, // No right padding - screenshots go edge to edge
            top: 20,
            bottom: MediaQuery.of(context).padding.bottom + 32,
          ),
          decoration: const BoxDecoration(
            color: Colors.black,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Section Header
              _buildSectionHeader('About'),
              
              const SizedBox(height: 12),

              // Game Description - needs right padding
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: _buildGameDescription(),
              ),

              const SizedBox(height: 24),

              // Screenshots Section Header
              _buildSectionHeader('Screenshots'),
              
              const SizedBox(height: 12),

              // Screenshots - starts at 24 padding, ends at screen edge
              _buildScreenshotsSection(),

              const SizedBox(height: 28),

              // Play Button - needs right padding
              Padding(
                padding: const EdgeInsets.only(right: 24),
                child: _buildPlayButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF909090),   // Dark
                Color(0xFFD0D0D0),   // Light
                Color(0xFFFFFFFF),   // Bright center
                Color(0xFFD0D0D0),   // Light
                Color(0xFF909090),   // Dark
              ],
              stops: [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGameDescription() {
    return Text(
      'Experience the thrill of ${widget.game.name}! Spin the reels and discover amazing bonus features, free spins, and massive win potential. This premium slot game offers stunning visuals and exciting gameplay.',
      style: AppTypography.bodyMedium.copyWith(
        color: Colors.white.withOpacity(0.7),
        height: 1.6,
      ),
    );
  }

  Widget _buildScreenshotsSection() {
    // Use screenshots from game model, or fallback to generated paths
    List<String> screenshotPaths;
    
    if (widget.game.screenshots != null && widget.game.screenshots!.isNotEmpty) {
      screenshotPaths = widget.game.screenshots!;
    } else {
      // Fallback: generate paths based on game id
      final ext = 'jpg';
      screenshotPaths = [
        'assets/images/game-screenshots/${widget.game.id}/screenshot_1.$ext',
        'assets/images/game-screenshots/${widget.game.id}/screenshot_2.$ext',
        'assets/images/game-screenshots/${widget.game.id}/screenshot_3.$ext',
      ];
    }

    return SizedBox(
      height: 160, // Bigger screenshots
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero, // No left padding, starts where parent padding ends
        clipBehavior: Clip.none,
        itemCount: screenshotPaths.length,
        itemBuilder: (context, index) {
          final isLast = index == screenshotPaths.length - 1;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 12),
            child: GestureDetector(
              onTap: () => _openFullScreenGallery(screenshotPaths, index),
              child: Container(
                width: 240, // Bigger width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    screenshotPaths[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.backgroundCard,
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.white.withOpacity(0.3),
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openFullScreenGallery(List<String> paths, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.95),
      builder: (context) => _FullScreenGallery(
        imagePaths: paths,
        initialIndex: initialIndex,
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _playGame,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF909090),   // Dark edge
                  Color(0xFFB8B8B8),   // Medium
                  Color(0xFFE0E0E0),   // Light
                  Color(0xFFFFFFFF),   // Bright center highlight
                  Color(0xFFF5F5F5),   // Near white
                  Color(0xFFD8D8D8),   // Light
                  Color(0xFFB0B0B0),   // Medium
                  Color(0xFF888888),   // Dark edge
                ],
                stops: [0.0, 0.12, 0.3, 0.45, 0.55, 0.7, 0.88, 1.0],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFFD0D0D0),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
                BoxShadow(
                  color: const Color(0xFFB0B0B0).withOpacity(0.2 + _glowAnimation.value * 0.15),
                  blurRadius: 25,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_arrow_rounded,
                  color: Color(0xFF2A2A2A),
                  size: 32,
                ),
                const SizedBox(width: 8),
                Text(
                  'PLAY NOW',
                  style: AppTypography.headingSmall.copyWith(
                    color: const Color(0xFF2A2A2A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// Full screen gallery for viewing screenshots
class _FullScreenGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _FullScreenGallery({
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Page View for swiping
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Center(
                  child: Image.asset(
                    widget.imagePaths[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported_rounded,
                      color: Colors.white24,
                      size: 60,
                    ),
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Page indicators
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imagePaths.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: _currentIndex == index
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Image counter
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Text(
                  '${_currentIndex + 1} / ${widget.imagePaths.length}',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
