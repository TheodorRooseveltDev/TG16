import '../../../core/config/supabase_config.dart';
import '../models/game.dart';

class GamesRepository {
  static const String _tableName = 'games';

  /// Fetch all games from Supabase
  Future<List<Game>> fetchGames() async {
    final response = await SupabaseConfig.client
        .from(_tableName)
        .select()
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((json) => Game.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch a single game by ID
  Future<Game?> fetchGameById(String id) async {
    final response = await SupabaseConfig.client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Game.fromJson(response as Map<String, dynamic>);
  }

  /// Fetch games by tag
  Future<List<Game>> fetchGamesByTag(String tag) async {
    final response = await SupabaseConfig.client
        .from(_tableName)
        .select()
        .eq('tag', tag);

    return (response as List<dynamic>)
        .map((json) => Game.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Fetch premium/featured games (games with animated icons)
  Future<List<Game>> fetchPremiumGames() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .not('animated_icon', 'is', null)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Game.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fall back to all games on error
      return fetchGames();
    }
  }
}
