import '../../../core/config/supabase_config.dart';

class Game {
  final String id;
  final String name;
  final String iframe;
  final String? icon;           // Static icon URL (network)
  final String? animatedIcon;   // Animated icon URL (network, GIF/WebP)
  final String? banner;         // Banner image URL for game detail page
  final String? tag;
  final List<String>? screenshots;

  // Legacy support for local assets
  final String? image;          // Legacy local asset path
  final String? animatedLogo;   // Legacy local animated SVG path

  // Cached computed URLs (computed once at construction)
  final String _displayIcon;
  final String _displayBanner;
  final List<String> _displayScreenshots;

  Game({
    required this.id,
    required this.name,
    required this.iframe,
    this.icon,
    this.animatedIcon,
    this.banner,
    this.tag,
    this.screenshots,
    this.image,
    this.animatedLogo,
  })  : _displayIcon = _computeDisplayIcon(animatedIcon, icon, image),
        _displayBanner = _computeDisplayBanner(banner, animatedIcon, icon, image),
        _displayScreenshots = _computeDisplayScreenshots(screenshots);

  /// Convert a path to full URL if needed
  static String _toFullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    // Already a full URL
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Convert relative path to Supabase storage URL
    return SupabaseConfig.getStorageUrl(path);
  }

  static String _computeDisplayIcon(String? animatedIcon, String? icon, String? image) {
    if (animatedIcon != null && animatedIcon.isNotEmpty) {
      return _toFullUrl(animatedIcon);
    }
    if (icon != null && icon.isNotEmpty) {
      return _toFullUrl(icon);
    }
    if (image != null && image.isNotEmpty) {
      return image; // Legacy local asset - don't convert
    }
    return '';
  }

  static String _computeDisplayBanner(String? banner, String? animatedIcon, String? icon, String? image) {
    if (banner != null && banner.isNotEmpty) {
      return _toFullUrl(banner);
    }
    return _computeDisplayIcon(animatedIcon, icon, image);
  }

  static List<String> _computeDisplayScreenshots(List<String>? screenshots) {
    if (screenshots == null || screenshots.isEmpty) return const [];
    return screenshots.map((s) => _toFullUrl(s)).toList();
  }

  /// Get the best available icon for display (cached)
  String get displayIcon => _displayIcon;

  /// Check if we have an animated icon
  bool get hasAnimatedIcon {
    return animatedIcon != null && animatedIcon!.isNotEmpty;
  }

  /// Get the banner image for game detail page (cached)
  String get displayBanner => _displayBanner;

  /// Get screenshots as full URLs (cached)
  List<String> get displayScreenshots => _displayScreenshots;

  /// Check if URL is a network URL
  static bool isNetworkUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    // Parse screenshots - can be array or null
    List<String>? screenshotsList;
    if (json['screenshots'] != null) {
      if (json['screenshots'] is List) {
        screenshotsList = (json['screenshots'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }
    }

    // Helper to safely get string or null
    String? getString(dynamic value) {
      if (value == null) return null;
      final str = value.toString();
      if (str.isEmpty || str == 'null') return null;
      return str;
    }

    return Game(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      // Support both column names: api_url (database) and iframe (legacy)
      iframe: getString(json['api_url']) ?? getString(json['iframe']) ?? '',
      // Support both: logo_url (database) and icon (legacy)
      icon: getString(json['logo_url']) ?? getString(json['icon']),
      // Support both: animated_logo_url (database) and animated_icon (legacy)
      animatedIcon: getString(json['animated_logo_url']) ?? getString(json['animated_icon']) ?? getString(json['animatedIcon']),
      // Support both: banner_url (database) and banner (legacy)
      banner: getString(json['banner_url']) ?? getString(json['banner']),
      tag: getString(json['tag']),
      screenshots: screenshotsList,
      // Legacy fields
      image: getString(json['image']),
      animatedLogo: getString(json['animatedLogo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iframe': iframe,
      'icon': icon,
      'animated_icon': animatedIcon,
      'banner': banner,
      'tag': tag,
      'screenshots': screenshots,
      'image': image,
      'animatedLogo': animatedLogo,
    };
  }

  /// Create a copy with optional overrides
  Game copyWith({
    String? id,
    String? name,
    String? iframe,
    String? icon,
    String? animatedIcon,
    String? banner,
    String? tag,
    List<String>? screenshots,
    String? image,
    String? animatedLogo,
  }) {
    return Game(
      id: id ?? this.id,
      name: name ?? this.name,
      iframe: iframe ?? this.iframe,
      icon: icon ?? this.icon,
      animatedIcon: animatedIcon ?? this.animatedIcon,
      banner: banner ?? this.banner,
      tag: tag ?? this.tag,
      screenshots: screenshots ?? this.screenshots,
      image: image ?? this.image,
      animatedLogo: animatedLogo ?? this.animatedLogo,
    );
  }
}
