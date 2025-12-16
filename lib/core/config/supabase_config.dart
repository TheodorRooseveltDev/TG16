import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get storageBucket => dotenv.env['SUPABASE_STORAGE_BUCKET'] ?? 'assets';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await dotenv.load(fileName: '.env');

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// Get public URL for a storage file
  /// Converts relative paths like /assets/images/banners/game_banner_1.png
  /// to full Supabase storage URLs
  static String getStorageUrl(String path) {
    if (path.isEmpty) return '';

    // If it's already a full URL, return as-is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    // Remove leading slash if present
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;

    // Remove 'assets/' prefix if it matches the bucket name to avoid duplication
    // Database paths: /assets/images/... -> images/...
    if (cleanPath.startsWith('assets/')) {
      cleanPath = cleanPath.substring(7); // Remove 'assets/'
    }

    // Construct storage URL
    final url = client.storage.from(storageBucket).getPublicUrl(cleanPath);
    return url;
  }
}
